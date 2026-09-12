"""Chat endpoints: send a message (grounded in the user's latest risk) and list history."""
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from predictions.models import Assessment
from .models import ChatMessage
from .serializers import ChatMessageSerializer
from .llm import get_provider

_HISTORY_TURNS = 12  # how much prior conversation to send to the model


def _user_name(user) -> str:
    """Best available display name: profile full name, else the username."""
    full = getattr(getattr(user, "profile", None), "full_name", "") or ""
    return full.strip() or user.username


def _system_prompt(user) -> str:
    name = _user_name(user)
    base = (
        "You are Aegis, a warm and encouraging health assistant inside a preventive-health app. "
        f"You are talking to {name} — address them by name when it feels natural. "
        "You help users understand their future risk of diabetes and chronic kidney disease and how "
        "lifestyle changes lower it. Reply in simple, kind, motivating language, kept short "
        "(2-4 short paragraphs at most). "
        "Very important: you are NOT a doctor. Never diagnose, never prescribe medicines or doses. "
        "For anything clinical or worrying, gently advise the user to see a real doctor."
    )
    latest = Assessment.objects.filter(user=user).order_by("-created_at").first()
    if latest:
        try:
            d = latest.result["prediction"]["diabetes"]
            k = latest.result["prediction"]["kidney"]
            base += (f" For context, the user's most recent screening showed diabetes risk "
                     f"{d['risk_percent']}% ({d['tier']} risk) and kidney risk "
                     f"{k['risk_percent']}% ({k['tier']} risk). Refer to this when relevant.")
        except (KeyError, TypeError):
            pass
    return base


class ChatView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        text = (request.data.get("message") or "").strip()
        if not text:
            return Response({"detail": "Message is required."},
                            status=status.HTTP_400_BAD_REQUEST)

        ChatMessage.objects.create(user=request.user, role="user", text=text)

        recent = list(ChatMessage.objects.filter(user=request.user)
                      .order_by("-created_at")[:_HISTORY_TURNS])[::-1]
        history = [{"role": m.role, "text": m.text} for m in recent]

        reply = get_provider().reply(_system_prompt(request.user), history)

        msg = ChatMessage.objects.create(
            user=request.user, role="assistant", text=reply)
        return Response(ChatMessageSerializer(msg).data, status=status.HTTP_200_OK)


class ChatHistoryView(generics.ListAPIView):
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ChatMessage.objects.filter(user=self.request.user)

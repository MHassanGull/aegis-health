"""Prediction endpoints: assess risk (and save), list history, schema lookup."""
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Assessment
from .schema import FEATURE_META
from .serializers import LifestyleInputSerializer, AssessmentSerializer
from .service import PredictionService


class SchemaView(APIView):
    """Expose the questionnaire schema so the app can build its form."""
    permission_classes = [permissions.AllowAny]
    authentication_classes = []   # truly public: ignore any (stale) token

    def get(self, request):
        return Response({"features": FEATURE_META})


class ModelCardView(APIView):
    """Transparency endpoint: the live model's architecture + real metrics."""
    permission_classes = [permissions.AllowAny]
    authentication_classes = []   # truly public: ignore any (stale) token

    def get(self, request):
        try:
            return Response(PredictionService.instance().model_card())
        except FileNotFoundError as exc:
            return Response({"detail": str(exc)},
                            status=status.HTTP_503_SERVICE_UNAVAILABLE)


class PredictView(APIView):
    """Run a full risk assessment for the authenticated user and store it."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = LifestyleInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        payload = serializer.validated_data

        try:
            result = PredictionService.instance().assess(payload)
        except FileNotFoundError as exc:
            return Response({"detail": str(exc)},
                            status=status.HTTP_503_SERVICE_UNAVAILABLE)

        record = Assessment.objects.create(
            user=request.user,
            inputs=payload,
            result=result,
            diabetes_risk=result["prediction"]["diabetes"]["risk"],
            kidney_risk=result["prediction"]["kidney"]["risk"],
        )
        return Response({"id": record.id, **result}, status=status.HTTP_200_OK)


class HistoryView(generics.ListAPIView):
    """List the authenticated user's past assessments (most recent first)."""
    serializer_class = AssessmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Assessment.objects.filter(user=self.request.user)

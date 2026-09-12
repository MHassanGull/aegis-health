"""Account views: registration and the current-user profile."""
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView

from .serializers import RegisterSerializer, ChangePasswordSerializer


class LoginView(TokenObtainPairView):
    """JWT login, tightly rate-limited to blunt password brute-forcing."""
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "login"


class RegisterView(generics.CreateAPIView):
    """Create a new user account (open, but rate-limited)."""
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "register"

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {"message": "Account created successfully.",
             "username": serializer.data["username"]},
            status=status.HTTP_201_CREATED,
        )


class MeView(APIView):
    """Return the authenticated user's basic profile."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        u = request.user
        return Response({"id": u.id, "username": u.username, "email": u.email})


class ChangePasswordView(APIView):
    """Change the signed-in user's password.

    Rate-limited on the login scope, because this endpoint verifies a password
    and would otherwise be a softer target for guessing than login itself.
    """

    permission_classes = [permissions.IsAuthenticated]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "login"

    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data, context={"request": request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        # The old JWT stays valid until it expires. Tell the client so it can
        # decide whether to ask the user to sign in again.
        return Response({"message": "Password changed."}, status=status.HTTP_200_OK)

from rest_framework import generics, permissions

from .models import UserProfile
from .serializers import ProfileSerializer


class ProfileView(generics.RetrieveUpdateAPIView):
    """GET / PATCH the authenticated user's profile (auto-created on first access)."""
    serializer_class = ProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        profile, _ = UserProfile.objects.get_or_create(user=self.request.user)
        return profile

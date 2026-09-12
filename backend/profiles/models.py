"""User profile: editable details + saved health basics to pre-fill the questionnaire."""
from django.conf import settings
from django.db import models


class UserProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="profile"
    )
    full_name = models.CharField(max_length=120, blank=True, default="")
    # Profile photo stored as a base64 JPEG string (small, compressed on-device).
    # Blank => fall back to the coloured-initial avatar. Kept in the DB so it
    # works with SQLite or Supabase Postgres without extra media hosting.
    avatar = models.TextField(blank=True, default="")
    # Saved health basics (used to pre-fill the questionnaire). Null = not set.
    sex = models.IntegerField(null=True, blank=True)          # 0 female, 1 male
    age = models.IntegerField(null=True, blank=True)          # 1-13 age band
    height_cm = models.FloatField(null=True, blank=True)
    weight_kg = models.FloatField(null=True, blank=True)
    avatar_color = models.CharField(max_length=9, default="#20A57A")
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Profile<{self.user.username}>"

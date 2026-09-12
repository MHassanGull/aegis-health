"""Persistence for a user's risk assessments (their history)."""
from django.conf import settings
from django.db import models


class Assessment(models.Model):
    """One saved risk assessment: the lifestyle input and the full result."""
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="assessments"
    )
    inputs = models.JSONField()                 # the 21 lifestyle answers
    result = models.JSONField()                 # prediction + factors + advice
    diabetes_risk = models.FloatField()
    kidney_risk = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.user} @ {self.created_at:%Y-%m-%d %H:%M}"

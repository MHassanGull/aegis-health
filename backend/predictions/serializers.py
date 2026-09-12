"""Input validation for the lifestyle questionnaire + history serialization."""
from rest_framework import serializers

from .models import Assessment
from .schema import FEATURE_META


class LifestyleInputSerializer(serializers.Serializer):
    """Validates the 21 lifestyle answers against the feature schema."""

    def to_internal_value(self, data):
        cleaned = {}
        errors = {}
        for name, meta in FEATURE_META.items():
            if name not in data:
                errors[name] = "This field is required."
                continue
            try:
                val = float(data[name])
            except (TypeError, ValueError):
                errors[name] = "Must be a number."
                continue
            if meta["type"] == "binary" and val not in (0, 1):
                errors[name] = "Must be 0 or 1."
            elif "min" in meta and not (meta["min"] <= val <= meta["max"]):
                errors[name] = f"Must be between {meta['min']} and {meta['max']}."
            cleaned[name] = val
        if errors:
            raise serializers.ValidationError(errors)
        return cleaned


class AssessmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Assessment
        fields = ("id", "inputs", "result", "diabetes_risk", "kidney_risk", "created_at")

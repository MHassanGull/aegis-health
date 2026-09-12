from rest_framework import serializers

from .models import UserProfile


class ProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source="user.username", read_only=True)
    email = serializers.EmailField(source="user.email", required=False)

    class Meta:
        model = UserProfile
        fields = ("username", "email", "full_name", "sex", "age",
                  "height_cm", "weight_kg", "avatar", "avatar_color", "updated_at")
        read_only_fields = ("username", "updated_at")

    def validate_avatar(self, value):
        # Reject oversized images (~500 KB of base64 ≈ a 370 KB photo).
        if value and len(value) > 500_000:
            raise serializers.ValidationError(
                "Image is too large. Please choose a smaller photo.")
        return value

    def update(self, instance, validated_data):
        user_data = validated_data.pop("user", {})
        email = user_data.get("email")
        if email is not None:
            instance.user.email = email
            instance.user.save(update_fields=["email"])
        return super().update(instance, validated_data)

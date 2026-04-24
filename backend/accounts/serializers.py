"""
Rapid Aid — Account Serializers
DRF serializers for user registration, profile, location updates, and password recovery.
"""

from rest_framework import serializers
from rest_framework.exceptions import PermissionDenied, ValidationError
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
import re

User = get_user_model()


def sanitize_input(value):
    """Strips HTML tags and script injections."""
    if isinstance(value, str):
        # Strip HTML/script tags
        value = re.sub(r'<[^>]*>', '', value)
        return value.strip()
    return value


class SanitizeMixin:
    """Mixin to sanitize all string fields."""
    def validate(self, attrs):
        for key, value in attrs.items():
            if isinstance(value, str):
                attrs[key] = sanitize_input(value)
        return super().validate(attrs)


class UserRegistrationSerializer(SanitizeMixin, serializers.ModelSerializer):
    """Serializer for new user registration."""

    # Explicit trim_whitespace=True
    username = serializers.CharField(trim_whitespace=True)
    email = serializers.EmailField(trim_whitespace=True)
    first_name = serializers.CharField(trim_whitespace=True, required=False, allow_blank=True)
    last_name = serializers.CharField(trim_whitespace=True, required=False, allow_blank=True)
    phone_number = serializers.CharField(trim_whitespace=True, required=False, allow_blank=True)

    def validate_email(self, value):
        from django.core.validators import validate_email
        value = value.strip()
        if value != value.lower():
            raise ValidationError("Email must be in strictly lowercase letters.")
        validate_email(value)
        return value

    password = serializers.CharField(write_only=True, min_length=8, trim_whitespace=False)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'password',
            'first_name', 'last_name', 'phone_number', 'role',
        ]

    def create(self, validated_data):
        password = validated_data.pop('password')
        # make_password / set_password used safely
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class UserDetailSerializer(SanitizeMixin, serializers.ModelSerializer):
    """Serializer for viewing user details after login."""

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'phone_number', 'role', 'is_available', 'date_joined',
        ]
        read_only_fields = ['id', 'username', 'role', 'date_joined']


UserProfileSerializer = UserDetailSerializer


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Custom login serializer to enforce portal-specific role checks."""

    portal_role = serializers.CharField(write_only=True, required=False, trim_whitespace=True)
    
    # Force trim_whitespace on username for login
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields[self.username_field].trim_whitespace = True

    def validate(self, attrs):
        portal_role = attrs.pop('portal_role', None)
        
        # Sanitize username
        username = attrs.get(self.username_field)
        if hasattr(username, 'strip'):
            username_clean = sanitize_input(username)
            if username_clean != username_clean.lower():
                raise ValidationError({self.username_field: "Email must be in strictly lowercase letters."})
            attrs[self.username_field] = username_clean

        data = super().validate(attrs)

        user = self.user

        # Strict Role Validation for Portal Access
        if portal_role:
            if portal_role == 'DISPATCHER' and not user.is_dispatcher:
                raise PermissionDenied('Unauthorized role for this portal')
            elif portal_role == 'RESPONDER' and not user.is_responder:
                raise PermissionDenied('Unauthorized role for this portal')
            elif portal_role == 'CITIZEN' and not user.is_citizen:
                raise PermissionDenied('Unauthorized role for this portal')

        data['user'] = UserDetailSerializer(user).data
        return data


class UserLocationSerializer(serializers.ModelSerializer):
    """Serializer for updating a user's GPS location."""

    latitude = serializers.FloatField(write_only=True)
    longitude = serializers.FloatField(write_only=True)

    class Meta:
        model = User
        fields = ['latitude', 'longitude']

    def update(self, instance, validated_data):
        from django.contrib.gis.geos import Point
        lat = validated_data['latitude']
        lng = validated_data['longitude']
        instance.location = Point(lng, lat, srid=4326)
        instance.save(update_fields=['location'])
        return instance


# ── Password Recovery Serializers ───────────────────────────────────

class PasswordResetRequestSerializer(SanitizeMixin, serializers.Serializer):
    """Serializer for step 1: Requesting a password reset code."""
    email = serializers.EmailField(trim_whitespace=True)

    def validate_email(self, value):
        from django.core.validators import validate_email
        value = value.strip()
        if value != value.lower():
            raise ValidationError("Email must be in strictly lowercase letters.")
        validate_email(value)
        return value


class PasswordResetVerifySerializer(SanitizeMixin, serializers.Serializer):
    """Serializer for step 2: Verifying the reset code strictly."""
    email = serializers.EmailField(trim_whitespace=True)
    reset_code = serializers.CharField(max_length=6, min_length=6, trim_whitespace=True)

    def validate_email(self, value):
        value = value.strip()
        if value != value.lower():
            raise ValidationError("Email must be in strictly lowercase letters.")
        return value

    def validate(self, attrs):
        attrs = super().validate(attrs)
        email = attrs.get('email')
        reset_code = attrs.get('reset_code')

        try:
            user = User.objects.get(email__iexact=email.strip())
        except User.DoesNotExist:
            raise ValidationError({'code': 'invalid_code'}, code='invalid_code')

        if not user.reset_code or user.reset_code != reset_code:
            raise ValidationError({'code': 'invalid_code'}, code='invalid_code')

        if not user.reset_code_expires_at or timezone.now() > user.reset_code_expires_at:
            raise ValidationError({'code': 'expired_code'}, code='expired_code')

        attrs['user'] = user
        return attrs


class PasswordResetConfirmSerializer(PasswordResetVerifySerializer):
    """Serializer for step 3: Confirming code and setting new password."""
    new_password = serializers.CharField(write_only=True, min_length=8, trim_whitespace=False)

    def validate(self, attrs):
        # reuse the verify logic
        attrs = super().validate(attrs)
        return attrs

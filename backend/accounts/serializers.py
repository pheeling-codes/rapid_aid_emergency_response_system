"""
Rapid Aid — Account Serializers
DRF serializers for user registration, profile, and location updates.
"""

from rest_framework import serializers
from rest_framework.exceptions import PermissionDenied
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

User = get_user_model()


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for new user registration."""

    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'password',
            'first_name', 'last_name', 'phone_number', 'role',
        ]

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class UserDetailSerializer(serializers.ModelSerializer):
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

    portal_role = serializers.CharField(write_only=True, required=False)

    def validate(self, attrs):
        portal_role = attrs.pop('portal_role', None)
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

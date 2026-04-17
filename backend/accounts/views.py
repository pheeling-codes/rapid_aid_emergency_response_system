"""
Rapid Aid — Account Views
API endpoints for user registration, profile, and location.
"""

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from django.contrib.auth import get_user_model

from .serializers import (
    UserRegistrationSerializer,
    UserProfileSerializer,
    UserLocationSerializer,
    CustomTokenObtainPairSerializer,
)

User = get_user_model()


class CustomTokenObtainPairView(TokenObtainPairView):
    """POST /api/auth/login/ — Custom login with role validation."""
    serializer_class = CustomTokenObtainPairSerializer


class RegisterView(generics.CreateAPIView):
    """POST /api/accounts/register/ — Create a new user."""
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]


class ProfileView(generics.RetrieveUpdateAPIView):
    """GET/PATCH /api/accounts/profile/ — Current user's profile."""
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user


class UpdateLocationView(generics.UpdateAPIView):
    """PATCH /api/accounts/location/ — Update current user's GPS location."""
    serializer_class = UserLocationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

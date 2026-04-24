"""
Rapid Aid — Account Views
API endpoints for user registration, profile, location, and password reset.
"""

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.throttling import ScopedRateThrottle
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.core.mail import send_mail
from datetime import timedelta
import random

from .serializers import (
    UserRegistrationSerializer,
    UserProfileSerializer,
    UserLocationSerializer,
    CustomTokenObtainPairSerializer,
    PasswordResetRequestSerializer,
    PasswordResetVerifySerializer,
    PasswordResetConfirmSerializer,
)

User = get_user_model()


class CustomTokenObtainPairView(TokenObtainPairView):
    """POST /api/auth/login/ — Custom login with role validation."""
    serializer_class = CustomTokenObtainPairSerializer


class RegisterView(generics.CreateAPIView):
    """POST /api/auth/register/ — Create a new user."""
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]


class ProfileView(generics.RetrieveUpdateAPIView):
    """GET/PATCH /api/auth/me/ — Current user's profile."""
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


# ── Password Recovery Views ──────────────────────────────────────────

class PasswordResetRequestView(APIView):
    """
    POST /api/auth/password-reset/
    Step 1: Accept registered email, generate 6-digit code, set 15m expiry, send email.
    """
    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'password_reset'

    def post(self, request, *args, **kwargs):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        email_clean = email.strip().lower()

        try:
            user = User.objects.get(email__iexact=email_clean)
            print(f"[SUCCESS] User record found for email: {email_clean}")
        except User.DoesNotExist:
            print(f"[FAILURE] No user record found for email: {email_clean}")
            return Response(
                {"error": "email_not_found", "message": "This email is not registered in our system."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Generate 6-digit code and 15-min expiration
        code = f"{random.randint(100000, 999999)}"
        user.reset_code = code
        user.reset_code_expires_at = timezone.now() + timedelta(minutes=15)
        user.save(update_fields=['reset_code', 'reset_code_expires_at'])

        # Clinical Vanguard Email Format (Minimal, Authoritative, High-Contrast)
        email_body = (
            "=========================================\n"
            "             R A P I D  A I D             \n"
            "=========================================\n"
            "SECURITY NOTIFICATION: PASSWORD RECOVERY  \n"
            "\n"
            "A password reset has been requested for   \n"
            "your account. Enter the verification code \n"
            "below to proceed with the recovery.\n"
            "\n"
            "      +-------------------------+\n"
            f"      |   {code[0]}   {code[1]}   {code[2]}   {code[3]}   {code[4]}   {code[5]}   |\n"
            "      +-------------------------+\n"
            "\n"
            "Code expires in exactly 15.00 minutes.\n"
            "If this request was not initiated by you,  \n"
            "ignore this transmission.\n"
            "=========================================\n"
        )

        send_mail(
            subject='Rapid Aid - Security Recovery Code',
            message=email_body,
            from_email='security@rapidaid.inc',
            recipient_list=[user.email],
            fail_silently=False,
        )

        return Response({'detail': 'If the email is registered, a reset code has been sent.'}, status=status.HTTP_200_OK)


class PasswordResetVerifyView(APIView):
    """
    POST /api/auth/password-reset/verify-code/
    Step 2: Validates the 6-digit code.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = PasswordResetVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response({'detail': 'Code is valid.'}, status=status.HTTP_200_OK)


class PasswordResetConfirmView(APIView):
    """
    POST /api/auth/password-reset/confirm/
    Step 3: Confirms the code again, updates password, triggers global security logout.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user = serializer.validated_data['user']
        new_password = serializer.validated_data['new_password']

        # Update password perfectly
        user.set_password(new_password)
        # Clear code
        user.reset_code = None
        user.reset_code_expires_at = None
        user.save(update_fields=['password', 'reset_code', 'reset_code_expires_at'])

        # Trigger global security logout: Invalidate all existing refresh tokens
        outstanding_tokens = OutstandingToken.objects.filter(user=user)
        for token in outstanding_tokens:
            BlacklistedToken.objects.get_or_create(token=token)

        return Response({'detail': 'Password has been successfully reset.'}, status=status.HTTP_200_OK)

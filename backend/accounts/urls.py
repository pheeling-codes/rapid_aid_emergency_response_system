from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

app_name = 'accounts'

urlpatterns = [
    # Auth (/api/auth/...)
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.CustomTokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Password Recovery
    path('password-reset/', views.PasswordResetRequestView.as_view(), name='password_reset_request'),
    path('password-reset/verify-code/', views.PasswordResetVerifyView.as_view(), name='password_reset_verify'),
    path('password-reset/confirm/', views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),

    # Profile & Location
    path('me/', views.ProfileView.as_view(), name='me'),
    path('profile/', views.ProfileView.as_view(), name='profile'),
    path('location/', views.UpdateLocationView.as_view(), name='update_location'),
]

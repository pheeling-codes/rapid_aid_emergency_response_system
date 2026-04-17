from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

app_name = 'accounts'

urlpatterns = [
    # Auth (/api/auth/...)
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.CustomTokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Protected Endpoints (For testing / me)
    path('me/', views.ProfileView.as_view(), name='me'),

    # Profile Profile/Location
    path('profile/', views.ProfileView.as_view(), name='profile'),
    path('location/', views.UpdateLocationView.as_view(), name='update_location'),
]

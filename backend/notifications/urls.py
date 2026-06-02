from django.urls import path

from . import views

app_name = 'notifications'

urlpatterns = [
    path('register-token/', views.RegisterFCMTokenView.as_view(), name='register_fcm_token'),
    path('queued/', views.PendingNotificationsView.as_view(), name='queued_notifications'),
]

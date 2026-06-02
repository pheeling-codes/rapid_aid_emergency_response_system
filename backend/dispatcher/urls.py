from django.urls import path
from . import views, admin_views

app_name = 'dispatcher'

urlpatterns = [
    # Health
    path('health/', views.DispatcherHealthView.as_view(), name='health'),

    # Admin Dashboard & Dispatch
    path('dashboard/stats/', admin_views.DashboardStatsView.as_view(), name='dashboard_stats'),
    path('incidents/<uuid:incident_id>/closest_responders/', admin_views.ClosestRespondersView.as_view(), name='closest_responders'),
    path('incidents/<uuid:incident_id>/dispatch/', admin_views.ManualDispatchView.as_view(), name='manual_dispatch'),

    # Admin Users Management
    path('users/', admin_views.AdminUsersView.as_view(), name='users_list'),
    path('users/<int:user_id>/', admin_views.AdminUsersDetailView.as_view(), name='users_detail'),
]

from django.urls import path

from . import views

app_name = 'incidents'

urlpatterns = [
    path('', views.IncidentListView.as_view(), name='list'),
    path('create/', views.IncidentCreateView.as_view(), name='create'),
    path('<int:pk>/', views.IncidentDetailView.as_view(), name='detail'),
    path('<int:pk>/nearest-responders/', views.NearestRespondersView.as_view(), name='nearest_responders'),
    path('<int:incident_pk>/logs/', views.ResponseLogListView.as_view(), name='response_logs'),
]

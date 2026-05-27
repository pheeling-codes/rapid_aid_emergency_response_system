from django.urls import path

from . import views

app_name = 'incidents'

urlpatterns = [
    path('', views.IncidentListView.as_view(), name='list'),
    path('create/', views.IncidentCreateView.as_view(), name='create'),
    path('<uuid:pk>/', views.IncidentDetailView.as_view(), name='detail'),
    path('<uuid:pk>/cancel/', views.IncidentCancelView.as_view(), name='cancel'),
    path('<uuid:pk>/nearest-responders/', views.NearestRespondersView.as_view(), name='nearest_responders'),
    path('<uuid:incident_pk>/logs/', views.ResponseLogListView.as_view(), name='response_logs'),
]

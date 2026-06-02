from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    # API endpoints
    path('api/auth/', include('accounts.urls')),
    path('api/incidents/', include('incidents.urls')),
    path('api/notifications/', include('notifications.urls')),

    # Dispatcher API
    path('api/dispatcher/', include('dispatcher.urls')),
]

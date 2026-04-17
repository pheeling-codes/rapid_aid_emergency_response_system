"""
Rapid Aid — WebSocket URL Routing
Defines the WebSocket URL patterns consumed by the ASGI application.
"""

from django.urls import re_path

from . import consumers

websocket_urlpatterns = [
    re_path(r'ws/dispatch/$', consumers.IncidentConsumer.as_asgi()),
]

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions


class DispatcherHealthView(APIView):
    """GET /api/dispatcher/health/ — Check WebSocket/Channels health."""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        from channels.layers import get_channel_layer
        channel_layer = get_channel_layer()
        return Response({
            'status': 'ok',
            'channel_layer': type(channel_layer).__name__,
        })

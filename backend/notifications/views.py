from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status


class RegisterFCMTokenView(APIView):
    """POST /api/notifications/register-token/ — Save device FCM token."""
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        token = request.data.get('fcm_token')
        if not token:
            return Response(
                {'error': 'fcm_token is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        request.user.fcm_token = token
        request.user.save(update_fields=['fcm_token'])
        return Response({'status': 'FCM token registered.'})

class PendingNotificationsView(APIView):
    """GET/POST /api/notifications/queued/ — Get pending toast notifications and mark as read."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        from .models import NotificationQueue
        notifications = NotificationQueue.objects.filter(user=request.user, is_read=False)
        data = [{'id': n.id, 'message': n.message, 'created_at': n.created_at} for n in notifications]
        return Response({'results': data})

    def post(self, request):
        from .models import NotificationQueue
        NotificationQueue.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'status': 'marked as read'})

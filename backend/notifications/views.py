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

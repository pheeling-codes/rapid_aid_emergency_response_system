"""
Rapid Aid — FCM Push Notification Service
Sends push notifications to user devices via Firebase Cloud Messaging.
"""

import logging

from django.conf import settings

logger = logging.getLogger(__name__)


def _get_firebase_app():
    """Lazily initialize and return the Firebase Admin app."""
    import firebase_admin
    from firebase_admin import credentials

    if not firebase_admin._apps:
        cred_path = getattr(settings, 'FIREBASE_CREDENTIALS_PATH', None)
        if cred_path:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
        else:
            logger.warning(
                'FIREBASE_CREDENTIALS_PATH not set. '
                'FCM push notifications are disabled.'
            )
            return None
    return firebase_admin.get_app()


def send_push_notification(fcm_token: str, title: str, body: str, data: dict = None):
    """
    Send a push notification to a single device.

    Args:
        fcm_token: The device's FCM registration token.
        title: Notification title.
        body: Notification body text.
        data: Optional dict of key-value data payload.

    Returns:
        Message ID string on success, None on failure.
    """
    app = _get_firebase_app()
    if not app:
        logger.info(f'[FCM DISABLED] Would send to token={fcm_token[:20]}...: {title}')
        return None

    from firebase_admin import messaging

    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data=data or {},
        token=fcm_token,
    )

    try:
        response = messaging.send(message)
        logger.info(f'[FCM] Sent notification: {response}')
        return response
    except Exception as e:
        logger.error(f'[FCM] Failed to send notification: {e}')
        return None


def send_push_to_user(user, title: str, body: str, data: dict = None):
    """
    Send a push notification to a user if they have an FCM token.

    Args:
        user: CustomUser instance.
        title: Notification title.
        body: Notification body text.
        data: Optional data payload.
    """
    if not user.fcm_token:
        logger.info(f'[FCM] No FCM token for user {user.username}, skipping.')
        return None

    return send_push_notification(user.fcm_token, title, body, data)


def notify_responder_dispatched(responder, incident):
    """Send a dispatch notification to a responder."""
    return send_push_to_user(
        user=responder,
        title='🚨 New Emergency Dispatch',
        body=f'{incident.get_category_display()} at {incident.address or "unknown location"}',
        data={
            'type': 'DISPATCH',
            'incident_id': str(incident.id),
            'category': incident.category,
            'severity': incident.severity,
        },
    )


def notify_reporter_status_update(incident):
    """Notify the reporter that their incident status changed."""
    return send_push_to_user(
        user=incident.reporter,
        title=f'Incident Update: {incident.get_status_display()}',
        body=f'Your reported incident "{incident.title}" is now {incident.get_status_display()}.',
        data={
            'type': 'STATUS_UPDATE',
            'incident_id': str(incident.id),
            'status': incident.status,
        },
    )

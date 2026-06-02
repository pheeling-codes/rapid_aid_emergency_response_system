from django.db import models
from django.conf import settings

class NotificationQueue(models.Model):
    """
    Queue for next-login toast notifications (e.g., admin edited profile).
    """
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='queued_notifications')
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Notification Queue'
        verbose_name_plural = 'Notification Queues'
        ordering = ['-created_at']

    def __str__(self):
        return f'To {self.user.username}: {self.message[:20]}'

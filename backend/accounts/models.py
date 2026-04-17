"""
Rapid Aid — CustomUser Model
Extends Django's AbstractUser with PostGIS spatial location,
role-based access, and responder availability tracking.
"""

from django.contrib.auth.models import AbstractUser
from django.contrib.gis.db import models as gis_models
from django.db import models


class CustomUser(AbstractUser):
    """
    Custom user model for the Rapid Aid emergency response system.

    Roles:
        - CITIZEN: Can report incidents and track response.
        - DISPATCHER: Manages and assigns incoming incidents.
        - RESPONDER: Field responder who handles incidents.
    """

    class Role(models.TextChoices):
        CITIZEN = 'CITIZEN', 'Citizen'
        DISPATCHER = 'DISPATCHER', 'Dispatcher'
        RESPONDER = 'RESPONDER', 'Responder'

    # ── Spatial ──────────────────────────────────────────────
    location = gis_models.PointField(
        geography=True,  # Uses SRID 4326 (WGS84) for real-world coordinates
        srid=4326,
        null=True,
        blank=True,
        help_text='Last known GPS location of the user (longitude, latitude).',
    )

    # ── Role & Availability ─────────────────────────────────
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.CITIZEN,
        db_index=True,
        help_text='Determines access level and system behavior.',
    )
    is_available = models.BooleanField(
        default=False,
        db_index=True,
        help_text='Whether the responder is currently available for dispatch.',
    )

    # ── Contact & Push ──────────────────────────────────────
    phone_number = models.CharField(
        max_length=20,
        blank=True,
        default='',
        help_text='Contact phone number.',
    )
    fcm_token = models.CharField(
        max_length=255,
        blank=True,
        default='',
        help_text='Firebase Cloud Messaging token for push notifications.',
    )

    # ── Timestamps ──────────────────────────────────────────
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        ordering = ['-date_joined']

    def __str__(self):
        return f'{self.get_full_name() or self.username} ({self.get_role_display()})'

    @property
    def is_responder(self):
        return self.role == self.Role.RESPONDER

    @property
    def is_dispatcher(self):
        return self.role == self.Role.DISPATCHER

    @property
    def is_citizen(self):
        return self.role == self.Role.CITIZEN

"""
Rapid Aid — Incident & ResponseLog Models
Core transactional models for the emergency response system.

Uses PostGIS PointField for spatial queries and GeoDjango's
ST_Distance for the nearest-responder algorithm.
"""

import uuid

from django.conf import settings
from django.contrib.gis.db import models as gis_models
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.measure import D
from django.db import models


class Incident(models.Model):
    """
    Core incident model representing an emergency event.

    Tracks the lifecycle from REPORTED → DISPATCHED → EN_ROUTE →
    ON_SCENE → RESOLVED (or CANCELLED).
    """

    # ── Core ──────────────────────────────────────────────────
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # ── Category Choices ────────────────────────────────────
    class Category(models.TextChoices):
        MEDICAL = 'MEDICAL', 'Medical Emergency'
        FIRE = 'FIRE', 'Fire'
        CRIME = 'CRIME', 'Crime'
        ACCIDENT = 'ACCIDENT', 'Road Accident'
        NATURAL_DISASTER = 'NATURAL_DISASTER', 'Natural Disaster'
        OTHER = 'OTHER', 'Other'

    # ── Severity Choices ────────────────────────────────────
    class Severity(models.TextChoices):
        LOW = 'LOW', 'Low'
        MEDIUM = 'MEDIUM', 'Medium'
        HIGH = 'HIGH', 'High'
        CRITICAL = 'CRITICAL', 'Critical'

    # ── Status Choices ──────────────────────────────────────
    class Status(models.TextChoices):
        PENDING = 'PENDING', 'Pending'
        ASSIGNED = 'ASSIGNED', 'Assigned'
        EN_ROUTE = 'EN_ROUTE', 'En Route'
        RESOLVED = 'RESOLVED', 'Resolved'

    # ── Spatial ──────────────────────────────────────────────
    location = gis_models.PointField(
        geography=True,
        srid=4326,
        help_text='GPS coordinates of the emergency (longitude, latitude).',
    )
    address = models.CharField(
        max_length=500,
        blank=True,
        default='',
        help_text='Human-readable address of the emergency location.',
    )

    # ── Classification ──────────────────────────────────────
    category = models.CharField(
        max_length=30,
        choices=Category.choices,
        default=Category.OTHER,
        db_index=True,
    )
    severity = models.CharField(
        max_length=10,
        choices=Severity.choices,
        default=Severity.MEDIUM,
        db_index=True,
    )
    status = models.CharField(
        max_length=15,
        choices=Status.choices,
        default=Status.PENDING,
        db_index=True,
    )

    # ── Description ─────────────────────────────────────────
    title = models.CharField(
        max_length=200,
        help_text='Short summary of the incident.',
    )
    description = models.TextField(
        blank=True,
        default='',
        help_text='Detailed description of the emergency.',
    )

    # ── Relationships ───────────────────────────────────────
    reporter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reported_incidents',
        help_text='The citizen who reported this incident.',
    )
    assigned_responder = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_incidents',
        help_text='The responder currently handling this incident.',
    )

    # ── Timestamps ──────────────────────────────────────────
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    resolved_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        verbose_name = 'Incident'
        verbose_name_plural = 'Incidents'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'severity']),
            models.Index(fields=['category', 'status']),
        ]

    def __str__(self):
        return f'[{self.get_status_display()}] {self.title} ({self.get_category_display()})'

    # ── Spatial Query: Nearest Responders ────────────────────
    def nearest_responders(self, radius_km=10, limit=10):
        """
        Find available responders within `radius_km` of this incident,
        ordered by distance (nearest first).

        Uses PostGIS ST_Distance via GeoDjango's Distance database
        function — this runs entirely in the database and is orders
        of magnitude faster than application-level distance math.

        Args:
            radius_km: Search radius in kilometres (default: 10).
            limit: Maximum number of responders to return (default: 10).

        Returns:
            QuerySet of CustomUser objects annotated with `distance`.

        Example:
            >>> incident = Incident.objects.get(pk=1)
            >>> nearby = incident.nearest_responders(radius_km=5)
            >>> for r in nearby:
            ...     print(f"{r.username} — {r.distance.km:.2f} km away")
        """
        from accounts.models import CustomUser

        if not self.location:
            return CustomUser.objects.none()

        return (
            CustomUser.objects
            .filter(
                role=CustomUser.Role.RESPONDER,
                is_available=True,
                location__isnull=False,
                location__distance_lte=(self.location, D(km=radius_km)),
            )
            .annotate(distance=Distance('location', self.location))
            .order_by('distance')[:limit]
        )


class ResponseLog(models.Model):
    """
    Audit trail for incident status transitions.

    Every time an incident's status changes (e.g., DISPATCHED → EN_ROUTE),
    a ResponseLog entry is created to maintain a complete history.
    """

    incident = models.ForeignKey(
        Incident,
        on_delete=models.CASCADE,
        related_name='response_logs',
        help_text='The incident this log entry belongs to.',
    )
    responder = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='response_logs',
        help_text='The responder who triggered this status change.',
    )
    status = models.CharField(
        max_length=15,
        choices=Incident.Status.choices,
        help_text='The new status after this transition.',
    )
    previous_status = models.CharField(
        max_length=15,
        choices=Incident.Status.choices,
        blank=True,
        default='',
        help_text='The status before this transition.',
    )
    note = models.TextField(
        blank=True,
        default='',
        help_text='Optional note explaining the status change.',
    )
    timestamp = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        verbose_name = 'Response Log'
        verbose_name_plural = 'Response Logs'
        ordering = ['-timestamp']

    def __str__(self):
        return (
            f'Incident #{self.incident_id}: '
            f'{self.previous_status or "—"} → {self.status} '
            f'by {self.responder} at {self.timestamp:%Y-%m-%d %H:%M}'
        )

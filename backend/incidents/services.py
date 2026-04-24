"""
Rapid Aid — Incidents Service Layer
Implements the core DispatchEngine spatial intelligence routing logic.
"""

from typing import List, Tuple
from django.contrib.gis.geos import GEOSGeometry, Point
from django.contrib.gis.geos.error import GEOSException
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.measure import D
from django.core.exceptions import ValidationError

from accounts.models import CustomUser
from incidents.models import Incident

class DispatchService:
    """
    Spatial intelligence layer for automated responder dispatching.
    Uses GeoDjango GIST indexes and PostGIS ST_Distance logic.
    """

    @staticmethod
    def validate_coordinates(lng: float, lat: float) -> Point:
        """
        Validates raw coordinates using GEOSGeometry.
        Catches malformed bounds or structures to prevent DB crash.
        """
        try:
            # WKT representation
            point_wkt = f"POINT({lng} {lat})"
            geom = GEOSGeometry(point_wkt, srid=4326)
            if not isinstance(geom, Point):
                raise ValidationError("Geometry is not a Point.")
            if not (-180 <= geom.x <= 180) or not (-90 <= geom.y <= 90):
                raise ValidationError("Coordinates out of valid GPS bounds.")
            if geom.x == 0.0 and geom.y == 0.0:
                raise ValidationError("Rejected 'Null Island' raw ping (0.0, 0.0).")
            return geom
        except (ValueError, GEOSException) as e:
            raise ValidationError(f"Invalid GPS coordinates provided: {e}")

    @staticmethod
    def get_nearest_responders(incident_id: str, limit: int = 5) -> List[CustomUser]:
        """
        Fetches the active responders closest to the Incident using Sub-Millisecond 
        Database Spatial Index queries (GIST) rather than application layer math.

        Internal math is resolved natively in meters by PostGIS (Geography objects), 
        annotated and yielded as km.
        """
        try:
            incident = Incident.objects.get(id=incident_id)
        except Incident.DoesNotExist:
            raise ValueError("Incident not found.")

        if not incident.location:
            return []

        # Validate geometry on the incident to lock out corrupt state queries
        target_point = DispatchService.validate_coordinates(
            incident.location.x, 
            incident.location.y
        )

        return (
            CustomUser.objects
            .filter(
                role=CustomUser.Role.RESPONDER,
                is_available=True,
                location__isnull=False,
                location__distance_lte=(target_point, D(km=50))  # Empty Horizon Bound
            )
            .annotate(distance=Distance('location', target_point))
            .order_by('distance')[:limit]
        )

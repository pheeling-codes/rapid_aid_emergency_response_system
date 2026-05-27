"""
Rapid Aid — Incident Serializers
DRF serializers for incident CRUD and response log entries.
"""

from rest_framework import serializers
from django.contrib.gis.geos import Point

from .models import Incident, ResponseLog


class ResponseLogSerializer(serializers.ModelSerializer):
    """Read-only serializer for response log entries."""

    responder_name = serializers.CharField(source='responder.get_full_name', read_only=True)

    class Meta:
        model = ResponseLog
        fields = [
            'id', 'incident', 'responder', 'responder_name',
            'status', 'previous_status', 'note', 'timestamp',
        ]
        read_only_fields = ['id', 'timestamp']


class IncidentSerializer(serializers.ModelSerializer):
    """Serializer for listing and retrieving incidents."""

    reporter_name = serializers.CharField(source='reporter.get_full_name', read_only=True)
    responder_name = serializers.CharField(
        source='assigned_responder.get_full_name', read_only=True, default=None,
    )
    responder_location = serializers.SerializerMethodField()
    response_logs = ResponseLogSerializer(many=True, read_only=True)
    ref_id = serializers.CharField(read_only=True)
    evidences = serializers.SerializerMethodField()
    location_coords = serializers.SerializerMethodField()

    class Meta:
        model = Incident
        fields = [
            'id', 'ref_id', 'title', 'description', 'category', 'severity',
            'status', 'address', 'location_coords', 'reporter', 'reporter_name',
            'assigned_responder', 'responder_name', 'responder_location',
            'response_logs', 'evidences', 'created_at', 'updated_at', 'resolved_at',
        ]
        read_only_fields = [
            'id', 'ref_id', 'reporter', 'created_at', 'updated_at', 'resolved_at',
        ]

    def get_evidences(self, obj):
        return [e.image_base64 for e in obj.evidences.all()]

    def get_location_coords(self, obj):
        if obj.location:
            return {"lat": obj.location.y, "lng": obj.location.x}
        return None

    def get_responder_location(self, obj):
        if obj.assigned_responder and obj.assigned_responder.location:
            return {"lat": obj.assigned_responder.location.y, "lng": obj.assigned_responder.location.x}
        return None


class IncidentListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing incidents (excludes evidences and response_logs)."""

    reporter_name = serializers.CharField(source='reporter.get_full_name', read_only=True)
    responder_name = serializers.CharField(
        source='assigned_responder.get_full_name', read_only=True, default=None,
    )
    responder_location = serializers.SerializerMethodField()
    ref_id = serializers.CharField(read_only=True)
    location_coords = serializers.SerializerMethodField()

    class Meta:
        model = Incident
        fields = [
            'id', 'ref_id', 'title', 'description', 'category', 'severity',
            'status', 'address', 'location_coords', 'reporter', 'reporter_name',
            'assigned_responder', 'responder_name', 'responder_location',
            'created_at', 'updated_at', 'resolved_at',
        ]
        read_only_fields = [
            'id', 'ref_id', 'reporter', 'created_at', 'updated_at', 'resolved_at',
        ]

    def get_location_coords(self, obj):
        if obj.location:
            return {"lat": obj.location.y, "lng": obj.location.x}
        return None

    def get_responder_location(self, obj):
        if obj.assigned_responder and obj.assigned_responder.location:
            return {"lat": obj.assigned_responder.location.y, "lng": obj.assigned_responder.location.x}
        return None


class IncidentCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating new incidents with lat/lng input."""

    latitude = serializers.FloatField(write_only=True)
    longitude = serializers.FloatField(write_only=True)
    evidences = serializers.ListField(
        child=serializers.CharField(),
        write_only=True,
        required=False
    )

    class Meta:
        model = Incident
        fields = [
            'id', 'title', 'description', 'category', 'severity',
            'latitude', 'longitude', 'address', 'evidences',
        ]
        read_only_fields = ['id']

    def create(self, validated_data):
        evidences_data = validated_data.pop('evidences', [])
        lat = validated_data.pop('latitude')
        lng = validated_data.pop('longitude')
        validated_data['location'] = Point(lng, lat, srid=4326)
        validated_data['reporter'] = self.context['request'].user
        
        incident = super().create(validated_data)
        
        from .models import IncidentEvidence
        for base64_str in evidences_data:
            IncidentEvidence.objects.create(incident=incident, image_base64=base64_str)
            
        return incident


class NearestRespondersSerializer(serializers.Serializer):
    """Serializer for nearest responder query results."""

    id = serializers.IntegerField()
    username = serializers.CharField()
    first_name = serializers.CharField()
    last_name = serializers.CharField()
    phone_number = serializers.CharField()
    distance_km = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()

    def get_distance_km(self, obj):
        if hasattr(obj, 'distance') and obj.distance:
            return round(obj.distance.km, 2)
        return None

    def get_location(self, obj):
        if hasattr(obj, 'location') and obj.location:
            return {"lat": round(obj.location.y, 6), "lng": round(obj.location.x, 6)}
        return None

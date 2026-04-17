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
    response_logs = ResponseLogSerializer(many=True, read_only=True)

    class Meta:
        model = Incident
        fields = [
            'id', 'title', 'description', 'category', 'severity',
            'status', 'address', 'reporter', 'reporter_name',
            'assigned_responder', 'responder_name',
            'response_logs', 'created_at', 'updated_at', 'resolved_at',
        ]
        read_only_fields = [
            'id', 'reporter', 'created_at', 'updated_at', 'resolved_at',
        ]


class IncidentCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating new incidents with lat/lng input."""

    latitude = serializers.FloatField(write_only=True)
    longitude = serializers.FloatField(write_only=True)

    class Meta:
        model = Incident
        fields = [
            'id', 'title', 'description', 'category', 'severity',
            'latitude', 'longitude', 'address',
        ]
        read_only_fields = ['id']

    def create(self, validated_data):
        lat = validated_data.pop('latitude')
        lng = validated_data.pop('longitude')
        validated_data['location'] = Point(lng, lat, srid=4326)
        validated_data['reporter'] = self.context['request'].user
        return super().create(validated_data)


class NearestRespondersSerializer(serializers.Serializer):
    """Serializer for nearest responder query results."""

    id = serializers.IntegerField()
    username = serializers.CharField()
    first_name = serializers.CharField()
    last_name = serializers.CharField()
    phone_number = serializers.CharField()
    distance_km = serializers.SerializerMethodField()

    def get_distance_km(self, obj):
        if hasattr(obj, 'distance') and obj.distance:
            return round(obj.distance.km, 2)
        return None

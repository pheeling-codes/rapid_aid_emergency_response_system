"""
Rapid Aid — Incident Views
API endpoints for incident CRUD and nearest-responder queries.
"""

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Incident, ResponseLog
from .serializers import (
    IncidentSerializer,
    IncidentCreateSerializer,
    ResponseLogSerializer,
    NearestRespondersSerializer,
)


class IncidentListView(generics.ListAPIView):
    """GET /api/incidents/ — List all incidents."""
    serializer_class = IncidentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_dispatcher or user.is_staff:
            return Incident.objects.all()
        elif user.is_responder:
            return Incident.objects.filter(assigned_responder=user)
        else:
            return Incident.objects.filter(reporter=user)


class IncidentCreateView(generics.CreateAPIView):
    """POST /api/incidents/ — Report a new incident."""
    serializer_class = IncidentCreateSerializer
    permission_classes = [permissions.IsAuthenticated]


class IncidentDetailView(generics.RetrieveUpdateAPIView):
    """GET/PATCH /api/incidents/<pk>/ — View or update an incident."""
    serializer_class = IncidentSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Incident.objects.all()


class NearestRespondersView(APIView):
    """
    GET /api/incidents/<pk>/nearest-responders/
    Find the nearest available responders to an incident within a radius.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        try:
            incident = Incident.objects.get(pk=pk)
        except Incident.DoesNotExist:
            return Response(
                {'error': 'Incident not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        radius_km = float(request.query_params.get('radius_km', 10))
        limit = int(request.query_params.get('limit', 10))

        responders = incident.nearest_responders(radius_km=radius_km, limit=limit)
        serializer = NearestRespondersSerializer(responders, many=True)
        return Response({
            'incident_id': incident.id,
            'radius_km': radius_km,
            'count': len(serializer.data),
            'responders': serializer.data,
        })


class ResponseLogListView(generics.ListCreateAPIView):
    """
    GET/POST /api/incidents/<incident_pk>/logs/
    View and create response log entries for an incident.
    """
    serializer_class = ResponseLogSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ResponseLog.objects.filter(incident_id=self.kwargs['incident_pk'])

    def perform_create(self, serializer):
        incident = Incident.objects.get(pk=self.kwargs['incident_pk'])
        previous_status = incident.status
        new_status = serializer.validated_data['status']

        # Update the incident status
        incident.status = new_status
        if new_status == Incident.Status.RESOLVED:
            from django.utils import timezone
            incident.resolved_at = timezone.now()
        incident.save()

        serializer.save(
            incident=incident,
            responder=self.request.user,
            previous_status=previous_status,
        )

import datetime
import math
from django.utils import timezone
from django.db import transaction
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
from accounts.models import BlacklistedEmail
from incidents.models import Incident
from notifications.models import NotificationQueue
from django.contrib.gis.db.models.functions import Distance

User = get_user_model()

class IsDispatcherOrAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and (request.user.is_dispatcher or request.user.is_superuser)

class DashboardStatsView(APIView):
    permission_classes = [IsDispatcherOrAdmin]

    def get(self, request):
        responders = User.objects.filter(role=User.Role.RESPONDER, is_active=True)
        total_units = responders.count()
        active_units = responders.filter(is_available=True).count()
        
        return Response({
            'total_units': total_units,
            'active_units': active_units,
        })

class ClosestRespondersView(APIView):
    permission_classes = [IsDispatcherOrAdmin]

    def get(self, request, incident_id):
        incident = get_object_or_404(Incident, id=incident_id)
        if not incident.location:
            return Response({'error': 'Incident has no location'}, status=status.HTTP_400_BAD_REQUEST)

        # Get top 3 nearest responders who are available and not suspended
        responders = User.objects.filter(
            role=User.Role.RESPONDER,
            is_active=True,
            is_available=True,
            is_suspended=False,
            location__isnull=False
        ).annotate(
            distance=Distance('location', incident.location)
        ).order_by('distance')[:3]

        results = []
        for r in responders:
            # distance is a Measure object
            dist_km = r.distance.km
            # rough ETA at 40 km/h
            eta_mins = max(1, math.ceil((dist_km / 40.0) * 60))
            results.append({
                'id': r.id,
                'name': r.get_full_name() or r.username,
                'distance_km': round(dist_km, 2),
                'eta_mins': eta_mins,
                'profile_image': r.profile_image,
            })

        return Response({'results': results})

class ManualDispatchView(APIView):
    permission_classes = [IsDispatcherOrAdmin]

    def post(self, request, incident_id):
        responder_id = request.data.get('responder_id')
        if not responder_id:
            return Response({'error': 'responder_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        incident = get_object_or_404(Incident, id=incident_id)
        responder = get_object_or_404(User, id=responder_id)

        with transaction.atomic():
            # Assign responder to incident
            incident.assigned_responder = responder
            incident.status = Incident.Status.EN_ROUTE
            incident.save()

            # Update responder status
            responder.is_available = False
            responder.save()

        return Response({'status': 'Dispatched successfully', 'incident_id': incident.id})

class AdminUsersView(APIView):
    permission_classes = [IsDispatcherOrAdmin]

    def get(self, request):
        users = User.objects.all().order_by('-date_joined')
        data = []
        for u in users:
            data.append({
                'id': u.id,
                'email': u.email,
                'name': u.get_full_name() or u.username,
                'first_name': u.first_name,
                'last_name': u.last_name,
                'role': u.role,
                'is_active': u.is_active,
                'is_available': u.is_available,
                'is_suspended': u.is_suspended,
                'phone_number': u.phone_number,
                'last_login': u.last_login,
                'date_joined': u.date_joined,
            })
        return Response({'results': data})

class AdminUsersDetailView(APIView):
    permission_classes = [IsDispatcherOrAdmin]

    def patch(self, request, user_id):
        user = get_object_or_404(User, id=user_id)
        
        old_name = user.get_full_name() or user.username
        new_first = request.data.get('first_name', user.first_name)
        new_last = request.data.get('last_name', user.last_name)
        is_suspended = request.data.get('is_suspended', user.is_suspended)

        name_changed = False
        with transaction.atomic():
            if new_first != user.first_name or new_last != user.last_name:
                user.first_name = new_first
                user.last_name = new_last
                name_changed = True
                
            user.is_suspended = is_suspended
            user.save()

            new_name = user.get_full_name() or user.username
            if name_changed:
                msg = f"An admin changed your name from '{old_name}' to '{new_name}'."
                NotificationQueue.objects.create(user=user, message=msg)

        return Response({'status': 'updated'})

    def delete(self, request, user_id):
        user = get_object_or_404(User, id=user_id)
        
        with transaction.atomic():
            # 1. Blacklist original email for 48 hours
            original_email = user.email
            locked_until = timezone.now() + datetime.timedelta(hours=48)
            BlacklistedEmail.objects.create(email=original_email, locked_until=locked_until)

            # 2. Obfuscate email
            timestamp = int(timezone.now().timestamp())
            prefix, domain = original_email.split('@') if '@' in original_email else (original_email, 'unknown.com')
            new_email = f"deleted_{timestamp}_{prefix}@{domain}"
            user.email = new_email
            # Also obfuscate username if it is the email
            if user.username == original_email:
                user.username = new_email

            # 3. Soft Delete
            user.is_active = False
            user.save()

        return Response({'status': 'deleted'})

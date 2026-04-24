import os
import sys
import uuid

# Bootstrap Django Environment directly to avoid IPython surrogate shell errors on Windows pipes
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rapid_aid.settings')
import django
django.setup()

from django.contrib.gis.geos import Point
from accounts.models import CustomUser
from incidents.models import Incident
from incidents.services import DispatchService

def run_test():
    print(f"\n[{'='*40}]")
    print("▶ RAPID AID DISPATCH ENGINE TEST")
    print(f"[{'='*40}]")

    # 1. Clean up old test incidents
    Incident.objects.filter(title="TEST-SANGOTEDO-EMERGENCY").delete()

    # 2. Get any citizen to reporter
    reporter = CustomUser.objects.filter(role=CustomUser.Role.CITIZEN).first()
    if not reporter:
        print("Creating a dummy citizen reporter...")
        reporter = CustomUser.objects.create_user(
            username=f"test_citizen_{uuid.uuid4().hex[:6]}", 
            email="citizen@rapidaid.org", 
            password="testPassword123!", 
            role=CustomUser.Role.CITIZEN
        )

    # 3. Create Incident near Novare Mall, Sangotedo 
    # Example coordinates: 6.469, 3.633 -> Point(lon, lat)
    incident_lng, incident_lat = 3.633, 6.469
    test_incident = Incident.objects.create(
        title="TEST-SANGOTEDO-EMERGENCY",
        description="Headless dispatch engine test.",
        category=Incident.Category.MEDICAL,
        severity=Incident.Severity.HIGH,
        location=Point(incident_lng, incident_lat, srid=4326),
        reporter=reporter
    )

    print(f"📍 INCIDENT CREATED: ID {test_incident.id}")
    print(f"📍 COORDINATES (Lng, Lat): ({incident_lng}, {incident_lat})\n")

    # 4. Trigger Spatial Dispatch Engine
    print("Executing DispatchService.get_nearest_responders(limit=3)...")
    closest_responders = DispatchService.get_nearest_responders(incident_id=test_incident.id, limit=3)

    if not closest_responders:
        print("⚠️ No available responders found! Did you run `python manage.py seed_responders`?")
        return

    print("\n✅ TOP 3 CLOSEST RESPONDERS:")
    print(f"{'-'*40}")
    for idx, resp in enumerate(closest_responders, 1):
        # The annotated distance is a Distance object, we extract .km
        dist_km = resp.distance.km if hasattr(resp, 'distance') else 0.0
        coords = f"({resp.location.x:.4f}, {resp.location.y:.4f})" if resp.location else "(None)"
        print(f"  {idx}. [ID: {resp.id}] {resp.first_name} {resp.last_name}")
        print(f"     Location: {coords}")
        print(f"     Distance: {dist_km:.2f} km\n")
        
    print(">>> SUPABASE DB CHECK: To verify this spatial math, cross-check these users and the incident in your Postgres cloud interface.")
    print(f"[{'='*40}]\n")

if __name__ == '__main__':
    run_test()

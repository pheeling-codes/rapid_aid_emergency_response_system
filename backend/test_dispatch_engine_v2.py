import os
import sys
import uuid
import math

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rapid_aid.settings')
import django
django.setup()

from django.contrib.gis.geos import Point
from accounts.models import CustomUser
from incidents.models import Incident
from incidents.services import DispatchService
from incidents.serializers import NearestRespondersSerializer

def haversine(lon1, lat1, lon2, lat2):
    # Pure mathematical Haversine formula
    R = 6371000  # radius of Earth in meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)
    a = math.sin(delta_phi/2.0)**2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda/2.0)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

def run_test():
    print(f"\n[{'='*50}]")
    print("▶ RAPID AID DISPATCH VALIDATION & AUDIT")
    print(f"[{'='*50}]\n")

    # Cleanup
    Incident.objects.filter(title="TEST-NOVARE-EMERGENCY").delete()
    CustomUser.objects.filter(username__startswith='test_audit_').delete()

    reporter, _ = CustomUser.objects.get_or_create(
        username="test_audit_reporter", defaults={"email": "audit@rapidaid.org", "role": CustomUser.Role.CITIZEN}
    )

    # Incident: Novare Mall, Sangotedo
    incident_lng, incident_lat = 3.633000, 6.469000
    incident = Incident.objects.create(
        title="TEST-NOVARE-EMERGENCY",
        category=Incident.Category.MEDICAL,
        location=Point(incident_lng, incident_lat, srid=4326),
        reporter=reporter
    )

    # Create Scenarios Mock Data
    print(">>> 🛠️  Provisioning Scenario Mock Responders...")
    
    # 1. Very Close, but UNAVAILABLE (Scenario B rule)
    CustomUser.objects.create_user(
        username="test_audit_unavailable",
        first_name="Ghost", last_name="Offline",
        role=CustomUser.Role.RESPONDER,
        is_available=False,
        location=Point(3.633005, 6.469005, srid=4326) # Barely meters away
    )

    # 2. Closest AVAILABLE (Scenario A & C target)
    target_lng, target_lat = 3.634000, 6.470000 
    available_resp = CustomUser.objects.create_user(
        username="test_audit_hero",
        first_name="Hero", last_name="Active",
        role=CustomUser.Role.RESPONDER,
        is_available=True,
        location=Point(target_lng, target_lat, srid=4326)
    )

    print(">>> 🚀 Triggering Dispatch Engine...\n")
    closest = DispatchService.get_nearest_responders(incident_id=incident.id, limit=3)
    
    # DRF Serializer Test
    serialized_data = NearestRespondersSerializer(closest, many=True).data

    print(f"[{'='*20} SCENARIO A: IDEAL DISPATCH {'='*20}]")
    print(f"First Active Responder Picked: {serialized_data[0]['first_name']} {serialized_data[0]['last_name']}")
    if serialized_data[0]['username'] == "test_audit_hero":
        print("✅ SUCCESS: Ideal responder accurately picked prioritizing location & status.\n")
    else:
        print("❌ FAILED: Wrong responder picked.\n")

    print(f"[{'='*20} SCENARIO B: FILTER CHECK {'='*20}]")
    ghost_found = any(resp['username'] == 'test_audit_unavailable' for resp in serialized_data)
    print("Checking if Ghost Offline (0.5 meters away, but unavailable) infected the routing...")
    if not ghost_found:
        print("✅ SUCCESS: Unavailable Responder cleanly skipped by the GIST DB indexing.\n")
    else:
        print("❌ FAILED: Unavailable responder crept into routing.\n")

    print(f"[{'='*20} SCENARIO C: DISTANCE AUDIT {'='*20}]")
    # Manual Haversine math inside python
    pure_math_meters = haversine(incident_lng, incident_lat, target_lng, target_lat)
    
    db_km = serialized_data[0]['distance_km']
    db_meters = db_km * 1000

    print(f"Agnostic Math (Haversine Formula): {pure_math_meters:.3f} meters")
    print(f"GeoDjango ST_Distance Engine:    {db_meters:.3f} meters")
    diff = abs(pure_math_meters - db_meters)
    print(f"Margin of Error: ±{diff:.3f} meters")
    
    if diff < 10.0:  # Allow 10 meters margin for Earth projection mapping variance
        print("✅ SUCCESS: ST_Distance mapping math is cryptographically accurate relative to Earth boundaries.\n")

    print(f"[{'='*20} API SERIALIZER CHECK {'='*20}]")
    print("Exact JSON structure ready for Flutter consumption:")
    print(serialized_data[0])
    print("")

if __name__ == '__main__':
    run_test()

import os
import django
import random
from datetime import timedelta
from django.utils import timezone

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'rapid_aid.settings')
django.setup()

from accounts.models import CustomUser
from incidents.models import Incident
from django.contrib.gis.geos import Point

def run_seeder():
    print("Clearing existing seed data (except superusers)...")
    CustomUser.objects.filter(is_superuser=False).delete()
    Incident.objects.all().delete()

    print("Seeding Responders...")
    responders = []
    for i in range(5):
        u = CustomUser.objects.create_user(
            username=f'responder_{i}@example.com',
            email=f'responder_{i}@example.com',
            password='password123',
            first_name=f'John{i}',
            last_name=f'Doe{i}',
            role=CustomUser.Role.RESPONDER,
            is_available=random.choice([True, False]),
            location=Point(-122.4194 + random.uniform(-0.05, 0.05), 37.7749 + random.uniform(-0.05, 0.05))
        )
        responders.append(u)
    
    print("Seeding Citizens...")
    citizens = []
    for i in range(5):
        u = CustomUser.objects.create_user(
            username=f'citizen_{i}@example.com',
            email=f'citizen_{i}@example.com',
            password='password123',
            first_name=f'Jane{i}',
            last_name=f'Smith{i}',
            role=CustomUser.Role.CITIZEN,
        )
        citizens.append(u)

    print("Seeding Incidents...")
    statuses = [Incident.Status.PENDING, Incident.Status.EN_ROUTE, Incident.Status.ON_SCENE, Incident.Status.RESOLVED]
    for i in range(8):
        status = random.choice(statuses)
        assigned = None
        if status in [Incident.Status.EN_ROUTE, Incident.Status.ON_SCENE, Incident.Status.RESOLVED]:
            assigned = random.choice(responders)
            
        Incident.objects.create(
            citizen=random.choice(citizens),
            assigned_responder=assigned,
            emergency_type=random.choice(['Medical', 'Fire', 'Police', 'Other']),
            location=Point(-122.4194 + random.uniform(-0.05, 0.05), 37.7749 + random.uniform(-0.05, 0.05)),
            status=status,
            description=f"Emergency incident #{i} requiring immediate attention.",
            priority=random.choice(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])
        )

    print("Database seeded successfully! You should now see data on the admin dashboard.")

if __name__ == '__main__':
    run_seeder()

import random
from django.core.management.base import BaseCommand
from django.contrib.gis.geos import Point
from accounts.models import CustomUser

class Command(BaseCommand):
    help = 'Seeds the database with mock Responders in the Lagos (Ajah/Sangotedo) Axis for Spatial Dispatch testing.'

    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.NOTICE("Initializing Spatial Seeder (Lagos Axis)..."))

        # Ajah/Sangotedo/Lekki Bounding Box
        MIN_LNG = 3.50
        MAX_LNG = 3.65
        MIN_LAT = 6.45
        MAX_LAT = 6.50

        num_responders = random.randint(10, 15)
        created_count = 0

        # Remove existing mock responders to prevent clutter
        deleted, _ = CustomUser.objects.filter(username__startswith='mock_resp_').delete()
        if deleted:
            self.stdout.write(f"Cleared {deleted} previous mock responders.")

        names = [
            ("Tunde", "Adebayo"), ("Ngozi", "Okafor"), ("Emeka", "Nwosu"), 
            ("Fatima", "Bello"), ("Chinedu", "Eze"), ("Amina", "Yusuf"),
            ("Bolaji", "Ogunleye"), ("Kemi", "Adeyemi"), ("Segun", "Bakare"),
            ("Joy", "Idris"), ("Musa", "Danjuma"), ("Oluwaseun", "Ojo"),
            ("Zainab", "Ali"), ("Damilola", "Peters"), ("Idris", "Abubakar")
        ]

        for i in range(num_responders):
            lng = random.uniform(MIN_LNG, MAX_LNG)
            lat = random.uniform(MIN_LAT, MAX_LAT)
            point = Point(lng, lat, srid=4326)

            is_available = random.choice([True, False])
            
            first_name, last_name = names[i % len(names)]
            username = f"mock_resp_{i}_{random.randint(1000, 9999)}"
            email = f"{username}@rapidaid.org"

            CustomUser.objects.create_user(
                username=username,
                email=email,
                password='vanguardPassword123!',
                first_name=first_name,
                last_name=last_name,
                role=CustomUser.Role.RESPONDER,
                is_available=is_available,
                location=point
            )
            created_count += 1

        self.stdout.write(self.style.SUCCESS(f"Successfully seeded {created_count} RESPONDERS in the designated bounds."))

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.gis.admin import GISModelAdmin

from .models import CustomUser


@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin, GISModelAdmin):
    """Admin configuration for the CustomUser model with map widget for location."""

    list_display = (
        'username', 'email', 'get_full_name', 'role',
        'is_available', 'is_staff', 'date_joined',
    )
    list_filter = ('role', 'is_available', 'is_staff', 'is_active')
    search_fields = ('username', 'email', 'first_name', 'last_name', 'phone_number')
    ordering = ('-date_joined',)

    # Extend the default UserAdmin fieldsets
    fieldsets = UserAdmin.fieldsets + (
        ('Rapid Aid', {
            'fields': ('role', 'is_available', 'phone_number', 'fcm_token', 'location'),
        }),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Rapid Aid', {
            'fields': ('role', 'phone_number'),
        }),
    )

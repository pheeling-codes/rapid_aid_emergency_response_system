from django.contrib import admin
from django.contrib.gis.admin import GISModelAdmin

from .models import Incident, ResponseLog


class ResponseLogInline(admin.TabularInline):
    """Inline display of response logs within the Incident admin."""
    model = ResponseLog
    extra = 0
    readonly_fields = ('responder', 'status', 'previous_status', 'note', 'timestamp')
    ordering = ('-timestamp',)


@admin.register(Incident)
class IncidentAdmin(GISModelAdmin):
    """Admin configuration for the Incident model with map widget."""

    list_display = (
        'id', 'title', 'category', 'severity', 'status',
        'reporter', 'assigned_responder', 'created_at',
    )
    list_filter = ('status', 'severity', 'category', 'created_at')
    search_fields = ('title', 'description', 'address', 'reporter__username')
    readonly_fields = ('created_at', 'updated_at')
    raw_id_fields = ('reporter', 'assigned_responder')
    ordering = ('-created_at',)
    inlines = [ResponseLogInline]

    fieldsets = (
        ('Emergency Details', {
            'fields': ('title', 'description', 'category', 'severity', 'status'),
        }),
        ('Location', {
            'fields': ('location', 'address'),
        }),
        ('People', {
            'fields': ('reporter', 'assigned_responder'),
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at', 'resolved_at'),
            'classes': ('collapse',),
        }),
    )


@admin.register(ResponseLog)
class ResponseLogAdmin(admin.ModelAdmin):
    """Admin configuration for the ResponseLog audit trail."""

    list_display = ('incident', 'responder', 'previous_status', 'status', 'timestamp')
    list_filter = ('status', 'timestamp')
    search_fields = ('incident__title', 'responder__username', 'note')
    readonly_fields = ('timestamp',)
    ordering = ('-timestamp',)

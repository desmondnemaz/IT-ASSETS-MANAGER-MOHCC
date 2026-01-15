
from django.contrib import admin
from .models import MOHProfile, NGOProfile

@admin.register(MOHProfile)
class MOHProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'department', 'position', 'station', 'is_complete')
    search_fields = ('user__username', 'department', 'position', 'station__station_name')
    list_filter = ('station', 'department')
    
    readonly_fields = ('user',)  # User should not be changed here

    def is_complete(self, obj):
        """Helper to show if profile has all required fields"""
        return all([obj.department, obj.position, obj.station])
    is_complete.boolean = True
    is_complete.short_description = "Complete?"


@admin.register(NGOProfile)
class NGOProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'organization_name', 'position', 'is_complete')
    search_fields = ('user__username', 'organization_name', 'position')
    
    readonly_fields = ('user',)

    def is_complete(self, obj):
        return all([obj.organization_name, obj.position])
    is_complete.boolean = True
    is_complete.short_description = "Complete?"

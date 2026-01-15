from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    # Fields to display in list view
    list_display = (
        'username', 
        'email', 
        'user_type', 
        'profile_complete', 
        'is_staff', 
        'is_active',
        'is_admin',
    )
    list_filter = ('user_type', 'is_staff', 'is_active','is_admin')
    search_fields = ('username', 'email', 'national_id')
    
    # Fields to edit in admin form
    fieldsets = (
        (None, {'fields': ('username', 'email', 'national_id', 'user_type')}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'is_admin', 'groups', 'user_permissions')}),
        ('Profile Status', {'fields': ('profile_complete',)}),
    )
    
    # Fields to show when adding a user
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        (None, {'fields': ('email', 'first_name', 'last_name', 'user_type', 'national_id', 'is_admin')}),
    )
    readonly_fields = ('profile_complete',)  # Admin cannot manually toggle it

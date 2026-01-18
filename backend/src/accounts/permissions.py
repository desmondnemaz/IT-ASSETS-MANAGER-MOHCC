# accounts/permissions.py

def get_admin_scope(user):
    """
    Returns a queryset filter dictionary representing the admin scope.
    Only meaningful if user.is_admin=True
    """
    if not user.is_admin or user.user_type != 'MOH':
        return None  # Regular users have no admin scope

    station = getattr(user.moh_profile, 'station', None)
    if not station:
        return None

    # HQ → access everything
    if station.station_type == 'HQ':
        return {}  # no filter, full access

    # PO → access province
    if station.station_type == 'PO':
        return {'station__province': station.province}

    # DO → access district
    if station.station_type == 'DO':
        return {'station__district': station.district}

    # FC → access only that station
    # FC → access only that station
    return {'station': station}


from rest_framework import permissions

class IsAssetAdmin(permissions.BasePermission):
    """
    Custom permission for Asset Management.
    - NC (HQ) Admins: Full Access (CRUD).
    - Other Admins: Read & Update only (No Create/Delete).
    """

    def has_permission(self, request, view):
        user = request.user
        if not user or not user.is_authenticated or not user.is_admin:
            return False

        # Get user station to determine type
        # Assuming MOH users for now as per "NC/Province/District" requirement
        if user.user_type != 'MOH':
            return False
            
        try:
            station = user.moh_profile.station
        except:
            return False

        if not station:
            return False

        # NC (HQ) has full access
        if station.station_type == 'HQ':
            return True

        # Others (PO, DO, FC)
        # Cannot Create (POST) or Delete (DELETE)
        # Allowed: GET, PUT, PATCH, HEAD, OPTIONS
        if request.method in ['POST', 'DELETE']:
            return False
            
        return True

    def has_object_permission(self, request, view, obj):
        # Users can only update assets within their scope.
        # This is partially handled by get_queryset filtering for list/retrieve,
        # but vital for Update to ensure they don't hijack an ID they shouldn't access.
        
        # We can reuse the filter logic or just check the obj against user station.
        # Since get_queryset already filters visibility, and DRF calls get_object() which uses get_queryset(),
        # the object is already guaranteed to be in scope.
        # So we just return True here, relying on has_permission deny for DELETE
        # and get_queryset for filtering.
        return True


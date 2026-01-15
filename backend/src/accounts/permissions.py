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
    return {'station': station}

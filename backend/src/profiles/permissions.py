from rest_framework.permissions import BasePermission

class IsProfileComplete(BasePermission):
    """
    Allows access only to users who have completed their profile.
    """

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.profile_complete
        )

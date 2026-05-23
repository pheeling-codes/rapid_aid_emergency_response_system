from rest_framework import permissions

class IsCitizen(permissions.BasePermission):
    """
    Allows access only to users with the CITIZEN role.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_citizen)

class IsResponder(permissions.BasePermission):
    """
    Allows access only to users with the RESPONDER role.
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_responder)

class IsDispatcher(permissions.BasePermission):
    """
    Allows access only to users with the DISPATCHER role (Admin).
    """
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and (request.user.is_dispatcher or request.user.is_staff))

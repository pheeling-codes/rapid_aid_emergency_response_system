/// Defines the user roles within the Rapid Aid framework.
enum UserRole { citizen, responder, admin }

/// Extension for display labels on [UserRole].
extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.responder:
        return 'Responder';
      case UserRole.admin:
        return 'Admin';
    }
  }

  /// Maps frontend role to the Django backend `CustomUser.Role` value.
  /// admin → DISPATCHER (backend has no ADMIN role).
  String get backendRole {
    switch (this) {
      case UserRole.citizen:
        return 'CITIZEN';
      case UserRole.responder:
        return 'RESPONDER';
      case UserRole.admin:
        return 'DISPATCHER';
    }
  }

  String get splashMessage {
    switch (this) {
      case UserRole.citizen:
        return 'IDENTITY SECURED';
      case UserRole.responder:
        return 'SECURE HANDSHAKE';
      case UserRole.admin:
        return 'COMMAND CENTER';
    }
  }

  String get portalLabel {
    switch (this) {
      case UserRole.citizen:
        return 'CITIZEN PORTAL';
      case UserRole.responder:
        return 'RESPONDER UNIT';
      case UserRole.admin:
        return 'ADMIN COMMAND CENTER';
    }
  }

  String get dashboardRoute {
    switch (this) {
      case UserRole.citizen:
        return '/citizen';
      case UserRole.responder:
        return '/responder';
      case UserRole.admin:
        return '/admin';
    }
  }

  /// Parses a backend role string (e.g., 'DISPATCHER') into a [UserRole].
  static UserRole fromBackendRole(String backendRole) {
    switch (backendRole.toUpperCase()) {
      case 'CITIZEN':
        return UserRole.citizen;
      case 'RESPONDER':
        return UserRole.responder;
      case 'DISPATCHER':
        return UserRole.admin;
      default:
        return UserRole.citizen;
    }
  }
}

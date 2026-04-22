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
        return 'RESPONDER PORTAL';
      case UserRole.admin:
        return 'ADMIN PORTAL';
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
}

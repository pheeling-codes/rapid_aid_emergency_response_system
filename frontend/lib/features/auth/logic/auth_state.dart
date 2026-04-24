import 'package:equatable/equatable.dart';
import '../domain/auth_enums.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
  resetSent,
  codeVerified,
  passwordUpdated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserRole selectedRole;
  final String? errorMessage;
  final String? successMessage;
  final String? userId;
  final String? userEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.selectedRole = UserRole.citizen,
    this.errorMessage,
    this.successMessage,
    this.userId,
    this.userEmail,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserRole? selectedRole,
    String? errorMessage,
    String? successMessage,
    String? userId,
    String? userEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      errorMessage: errorMessage,
      successMessage: successMessage,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedRole,
        errorMessage,
        successMessage,
        userId,
        userEmail,
      ];
}

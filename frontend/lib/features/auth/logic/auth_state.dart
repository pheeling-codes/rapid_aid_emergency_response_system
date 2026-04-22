import 'package:equatable/equatable.dart';
import '../domain/auth_enums.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
  resetSent,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserRole selectedRole;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.selectedRole = UserRole.citizen,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserRole? selectedRole,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedRole, errorMessage, successMessage];
}

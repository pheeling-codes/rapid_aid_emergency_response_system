import 'package:equatable/equatable.dart';
import '../domain/auth_enums.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user taps "Sign In".
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final UserRole role;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

/// Fired when the user taps "Create Account".
class AuthSignupRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final UserRole role;

  const AuthSignupRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [fullName, email, password, role];
}

/// Fired when the user requests a password reset.
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Fired when the user logs out.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Validate fields
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'The email or password entered is incomplete. All fields are required.',
      ));
      return;
    }

    emit(state.copyWith(
      status: AuthStatus.loading,
      selectedRole: event.role,
    ));

    try {
      // Simulate network call – replace with actual Dio/Supabase JWT call
      await Future.delayed(const Duration(seconds: 2));

      // Simulated success
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        selectedRole: event.role,
        successMessage: 'Login Successful',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Invalid credentials for this portal.',
      ));
    }
  }

  Future<void> _onSignup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.fullName.isEmpty || event.email.isEmpty || event.password.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'The email or password entered is incomplete. All fields are required.',
      ));
      return;
    }

    emit(state.copyWith(
      status: AuthStatus.loading,
      selectedRole: event.role,
    ));

    try {
      await Future.delayed(const Duration(seconds: 2));

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        selectedRole: event.role,
        successMessage: 'Account created successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Network connectivity issues. Attempting to reconnect...',
      ));
    }
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Please enter your email address.',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(
        status: AuthStatus.resetSent,
        successMessage: 'Password reset link sent to ${event.email}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Network connectivity issues. Attempting to reconnect...',
      ));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}

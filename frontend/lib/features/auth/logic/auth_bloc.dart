import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import '../domain/auth_enums.dart';
import '../domain/input_validators.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc manages the full authentication lifecycle:
/// - Session verification on startup (AuthCheckRequested)
/// - Login / Signup / Forgot Password with real API calls
/// - Client-side validation before network requests
/// - Dio error → user-friendly message mapping
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthVerifyResetCodeRequested>(_onVerifyResetCode);
    on<AuthConfirmPasswordResetRequested>(_onConfirmPasswordReset);
    on<AuthLogoutRequested>(_onLogout);
  }

  // ── Session Check (fired from splash screen) ─────────────

  Future<void> _onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final hasSession = await _authRepository.hasStoredSession();
      if (!hasSession) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      // Verify token against backend
      final profile = await _authRepository.getProfile();
      final backendRole = profile['role'] as String? ?? 'CITIZEN';
      final role = UserRoleLabel.fromBackendRole(backendRole);

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        selectedRole: role,
        userId: (profile['id'] ?? '').toString(),
        userEmail: profile['email'] as String?,
        successMessage: 'Session restored',
      ));
    } catch (e) {
      // Token invalid or expired (interceptor already tried refresh)
      await _authRepository.logout();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  // ── Login ─────────────────────────────────────────────────

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Client-side validation
    final emailError = InputValidators.validateEmail(event.email);
    if (emailError != null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: emailError,
      ));
      return;
    }

    final passwordError = InputValidators.validatePassword(event.password);
    if (passwordError != null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: passwordError,
      ));
      return;
    }

    emit(state.copyWith(
      status: AuthStatus.loading,
      selectedRole: event.role,
    ));

    try {
      final userData = await _authRepository.login(
        email: event.email,
        password: event.password,
        role: event.role,
      );

      final backendRole = userData['role'] as String? ?? event.role.backendRole;
      final role = UserRoleLabel.fromBackendRole(backendRole);

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        selectedRole: role,
        userId: (userData['id'] ?? '').toString(),
        userEmail: userData['email'] as String?,
        successMessage: 'Login Successful',
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapDioError(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  // ── Signup ────────────────────────────────────────────────

  Future<void> _onSignup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Client-side validation
    final nameError = InputValidators.validateFullName(event.fullName);
    if (nameError != null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: nameError,
      ));
      return;
    }

    final emailError = InputValidators.validateEmail(event.email);
    if (emailError != null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: emailError,
      ));
      return;
    }

    final passwordError = InputValidators.validatePassword(event.password);
    if (passwordError != null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: passwordError,
      ));
      return;
    }

    emit(state.copyWith(
      status: AuthStatus.loading,
      selectedRole: event.role,
    ));

    try {
      // Register the user
      await _authRepository.register(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
        role: event.role,
      );

      // Auto-login after successful registration
      final userData = await _authRepository.login(
        email: event.email,
        password: event.password,
        role: event.role,
      );

      final backendRole = userData['role'] as String? ?? event.role.backendRole;
      final role = UserRoleLabel.fromBackendRole(backendRole);

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        selectedRole: role,
        userId: (userData['id'] ?? '').toString(),
        userEmail: userData['email'] as String?,
        successMessage: 'Account created successfully',
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapDioError(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  // ── Password Recovery (3 Steps) ──────────────────────────

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final emailError = InputValidators.validateEmail(event.email);
    if (emailError != null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: emailError,
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.requestPasswordReset(email: event.email);
      emit(state.copyWith(
        status: AuthStatus.resetSent,
        successMessage: 'Password reset link sent to ${event.email}',
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapDioError(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> _onVerifyResetCode(
    AuthVerifyResetCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.verifyResetCode(
        email: event.email,
        code: event.code,
      );
      emit(state.copyWith(
        status: AuthStatus.codeVerified,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapDioError(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Invalid or expired code.',
      ));
    }
  }

  Future<void> _onConfirmPasswordReset(
    AuthConfirmPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final passwordError = InputValidators.validatePassword(event.newPassword);
    if (passwordError != null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: passwordError,
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.confirmPasswordReset(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(
        status: AuthStatus.passwordUpdated,
        successMessage: 'Security Updated',
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _mapDioError(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  // ── Logout ────────────────────────────────────────────────

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  // ── Error Mapping ─────────────────────────────────────────

  /// Maps Dio exceptions to localized, user-friendly error messages.
  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Network connectivity issues. Attempting to reconnect...';
      case DioExceptionType.connectionError:
        return 'Unable to reach the server. Please check your connection.';
      case DioExceptionType.badResponse:
        return _mapStatusCode(e.response);
      default:
        return 'An unexpected network error occurred.';
    }
  }

  String _mapStatusCode(Response? response) {
    if (response == null) return 'Server returned an empty response.';

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    switch (statusCode) {
      case 400:
        // Parse DRF validation errors
        if (data is Map) {
          // Check for specific field errors
          if (data.containsKey('username')) {
            final usernameErrors = data['username'];
            if (usernameErrors is List && usernameErrors.isNotEmpty) {
              final msg = usernameErrors.first.toString();
              if (msg.contains('already exists')) {
                return 'Email already registered. Please use a different email.';
              }
            }
          }
          if (data.containsKey('email')) {
            final emailErrors = data['email'];
            if (emailErrors is List && emailErrors.isNotEmpty) {
              return emailErrors.first.toString();
            }
          }
          if (data.containsKey('non_field_errors')) {
            final errors = data['non_field_errors'];
            if (errors is List && errors.isNotEmpty) {
              return errors.first.toString();
            }
          }
          if (data.containsKey('detail')) {
            return data['detail'].toString();
          }
        }
        return 'The email or password entered is incomplete. All fields are required.';
      case 401:
        return 'Invalid credentials. Please check your email and password.';
      case 403:
        if (data is Map && data.containsKey('detail')) {
          return data['detail'].toString();
        }
        return 'Invalid credentials for this portal.';
      case 404:
        if (data is Map && data['error'] == 'email_not_found') {
          return 'Email not found. Please check and try again.';
        }
        return 'Resource not found.';
      case 429:
        return 'Too many attempts. Please wait a moment and try again.';
      case 500:
        return 'Server error. Our team has been notified.';
      default:
        return 'Something went wrong (Error $statusCode).';
    }
  }
}

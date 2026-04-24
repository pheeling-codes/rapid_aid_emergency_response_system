import 'package:dio/dio.dart';
import 'token_storage.dart';
import '../domain/auth_enums.dart';
import '../domain/input_validators.dart';

/// Repository responsible for all authentication API calls
/// against the Django/Supabase backend.
///
/// Maps frontend models to the backend contract:
/// - Login: email → username field (SimpleJWT uses username)
/// - Signup: splits fullName into first_name/last_name
/// - Role: admin → DISPATCHER
class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required Dio dio,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage;

  /// POST /auth/login/
  /// Maps email → username for SimpleJWT compatibility.
  /// Sends portal_role for backend role validation.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final sanitizedEmail = InputValidators.sanitize(email);

    final response = await _dio.post(
      '/auth/login/',
      data: {
        'username': sanitizedEmail,
        'password': password,
        'portal_role': role.backendRole,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['access'] as String;
    final refreshToken = data['refresh'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    // Persist tokens securely
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Persist user metadata for fast access
    await _tokenStorage.saveUserMeta(
      role: userData['role'] as String? ?? role.backendRole,
      email: userData['email'] as String? ?? sanitizedEmail,
      userId: (userData['id'] ?? '').toString(),
    );

    return userData;
  }

  /// POST /auth/register/
  /// Splits fullName into first_name/last_name.
  /// Uses email as username (backend requires unique username).
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final sanitizedEmail = InputValidators.sanitize(email);
    final sanitizedName = InputValidators.sanitize(fullName);

    // Split full name into first/last
    final nameParts = sanitizedName.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';

    final response = await _dio.post(
      '/auth/register/',
      data: {
        'username': sanitizedEmail,
        'email': sanitizedEmail,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': role.backendRole,
      },
    );

    final userData = response.data as Map<String, dynamic>;
    return userData;
  }

  /// POST /api/auth/password-reset/
  /// Step 1: Generates 6-digit code and emails user.
  Future<void> requestPasswordReset({required String email}) async {
    final sanitizedEmail = InputValidators.sanitize(email);
    await _dio.post('/auth/password-reset/', data: {'email': sanitizedEmail});
  }

  /// POST /api/auth/password-reset/verify-code/
  /// Step 2: Validates the 6-digit code.
  Future<void> verifyResetCode({required String email, required String code}) async {
    final sanitizedEmail = InputValidators.sanitize(email);
    final sanitizedCode = InputValidators.sanitize(code);
    await _dio.post(
      '/auth/password-reset/verify-code/',
      data: {'email': sanitizedEmail, 'reset_code': sanitizedCode},
    );
  }

  /// POST /api/auth/password-reset/confirm/
  /// Step 3: Sets new password and triggers global token invalidation.
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final sanitizedEmail = InputValidators.sanitize(email);
    final sanitizedCode = InputValidators.sanitize(code);
    await _dio.post(
      '/auth/password-reset/confirm/',
      data: {
        'email': sanitizedEmail,
        'reset_code': sanitizedCode,
        'new_password': newPassword,
      },
    );
  }

  /// GET /auth/me/
  /// Verifies the current session against the persistent backend.
  /// Returns user profile data or throws on invalid/expired token.
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/me/');
    return response.data as Map<String, dynamic>;
  }

  /// Clear all stored tokens and user metadata.
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  /// Check if a valid token exists in storage.
  Future<bool> hasStoredSession() async {
    return await _tokenStorage.hasToken();
  }

  /// Get the stored user role from SharedPreferences (fast).
  UserRole? getStoredRole() {
    final roleStr = _tokenStorage.getUserRole();
    if (roleStr == null) return null;
    return UserRoleLabel.fromBackendRole(roleStr);
  }
}

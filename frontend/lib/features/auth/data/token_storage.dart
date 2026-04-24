import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure wrapper for JWT token persistence.
/// Access/Refresh tokens → FlutterSecureStorage (encrypted).
/// User metadata (role, email) → SharedPreferences (fast access).
class TokenStorage {
  static const _accessTokenKey = 'rapid_aid_access_token';
  static const _refreshTokenKey = 'rapid_aid_refresh_token';
  static const _userRoleKey = 'rapid_aid_user_role';
  static const _userEmailKey = 'rapid_aid_user_email';
  static const _userIdKey = 'rapid_aid_user_id';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  TokenStorage({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  // ── Token Operations ──────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _prefs.remove(_userRoleKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userIdKey);
  }

  /// Returns true if an access token exists in storage.
  Future<bool> hasToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // ── User Metadata (non-sensitive, fast access) ────────────

  Future<void> saveUserMeta({
    required String role,
    required String email,
    required String userId,
  }) async {
    await _prefs.setString(_userRoleKey, role);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userIdKey, userId);
  }

  String? getUserRole() => _prefs.getString(_userRoleKey);
  String? getUserEmail() => _prefs.getString(_userEmailKey);
  String? getUserId() => _prefs.getString(_userIdKey);
}

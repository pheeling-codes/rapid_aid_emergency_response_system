import 'package:dio/dio.dart';
import '../../features/auth/data/token_storage.dart';

/// Dio interceptor for automatic JWT token management.
///
/// - **onRequest**: Attaches `Authorization: Bearer <token>` to every request.
/// - **onError (401)**: Attempts token refresh via `/auth/token/refresh/`.
///   On success, retries the original request. On failure, clears tokens
///   and signals session expiry.
///
/// Uses a simple lock flag to prevent concurrent refresh storms during
/// parallel 401 responses.
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;

  bool _isRefreshing = false;

  /// Callback invoked when the refresh token itself has expired.
  /// Set externally by the AuthBloc to trigger logout/redirect.
  void Function()? onSessionExpired;

  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    final publicPaths = ['/auth/login/', '/auth/register/', '/auth/token/refresh/'];
    final isPublic = publicPaths.any((p) => options.path.contains(p));

    if (!isPublic) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only attempt refresh on 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't refresh if we're already on the refresh endpoint
    if (err.requestOptions.path.contains('/auth/token/refresh/')) {
      return handler.next(err);
    }

    // Prevent concurrent refresh attempts
    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _forceLogout();
        return handler.next(err);
      }

      // Attempt token refresh — use a fresh Dio instance to avoid recursion
      final refreshDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await refreshDio.post(
        '/auth/token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data['access'] != null) {
        final newAccessToken = response.data['access'] as String;
        await tokenStorage.updateAccessToken(newAccessToken);

        // Retry the original request with the new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await dio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } else {
        _forceLogout();
        return handler.next(err);
      }
    } on DioException {
      // Refresh token is expired or invalid
      _forceLogout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _forceLogout() {
    tokenStorage.clearTokens();
    onSessionExpired?.call();
  }
}

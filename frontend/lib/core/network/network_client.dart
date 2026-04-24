import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../../features/auth/data/token_storage.dart';

/// Configured Dio HTTP client for the Rapid Aid backend.
/// Base URL points to the Django DRF API.
/// Includes the [AuthInterceptor] for automatic JWT attachment and refresh.
class NetworkClient {
  late final Dio dio;
  late final AuthInterceptor authInterceptor;

  NetworkClient({
    required TokenStorage tokenStorage,
    String baseUrl = 'http://localhost:8000/api',
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    authInterceptor = AuthInterceptor(
      dio: dio,
      tokenStorage: tokenStorage,
    );

    dio.interceptors.addAll([
      authInterceptor,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }
}

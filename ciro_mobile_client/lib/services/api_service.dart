import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// A wrapper around the Dio HTTP client.
/// 
/// Configures base options, timeouts, and interceptors for
/// consistent communication with the CIRO backend.
class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            validateStatus: (status) => status! < 500, // Handle 4xx gracefully
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    // Add logging interceptor for development
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// Exposes the Dio instance for service classes to use.
  Dio get client => _dio;

  /// Helper for GET requests.
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// Helper for POST requests.
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  /// Helper for PATCH requests.
  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }
}

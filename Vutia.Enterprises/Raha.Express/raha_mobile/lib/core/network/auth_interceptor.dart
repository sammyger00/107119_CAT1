import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor that adds Bearer token to all requests
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await _storage.read(key: _tokenKey);

    // Add Bearer token if available
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If 401 Unauthorized, clear token
    if (err.response?.statusCode == 401) {
      _storage.delete(key: _tokenKey);
    }

    return handler.next(err);
  }

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _tokenKey, value: token);
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: _tokenKey);
  }

  /// Clear authentication token
  static Future<void> clearToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: _tokenKey);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

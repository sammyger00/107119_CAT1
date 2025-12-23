import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

/// API Client for making HTTP requests to the backend
class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(), // Adds Bearer token to requests
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    ]);
  }

  /// Get Dio instance for use with Retrofit
  Dio get dio => _dio;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');

      default:
        return NetworkException('An unexpected error occurred: ${error.message}');
    }
  }

  /// Handle HTTP response errors
  Exception _handleResponseError(Response? response) {
    if (response == null) {
      return ServerException('No response from server');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Extract error message from response
    String message = 'An error occurred';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message, data['errors']);
      case 500:
        return ServerException(message);
      default:
        return ServerException('Server error: $statusCode - $message');
    }
  }
}

/// Base exception class
abstract class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// Server exceptions
class ServerException extends ApiException {
  const ServerException(super.message);
}

/// Bad request (400)
class BadRequestException extends ApiException {
  const BadRequestException(super.message);
}

/// Unauthorized (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

/// Forbidden (403)
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

/// Not found (404)
class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

/// Validation errors (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;
  const ValidationException(super.message, this.errors);

  /// Get error messages for a specific field
  List<String>? getFieldErrors(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    if (fieldErrors is List) {
      return fieldErrors.map((e) => e.toString()).toList();
    }
    return null;
  }
}

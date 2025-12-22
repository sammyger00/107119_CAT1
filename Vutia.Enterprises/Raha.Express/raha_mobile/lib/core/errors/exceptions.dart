/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Server exception - API errors (4xx, 5xx)
class ServerException extends AppException {
  ServerException(String message, [int? statusCode])
      : super(message, statusCode);
}

/// Cache exception - Local storage errors
class CacheException extends AppException {
  CacheException(String message) : super(message);
}

/// Network exception - Connection errors
class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

/// Authentication exception - Auth errors
class AuthException extends AppException {
  AuthException(String message, [int? statusCode])
      : super(message, statusCode);
}

/// Validation exception - Input validation errors
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException(String message, [this.errors]) : super(message);
}

/// Timeout exception - Request timeout
class TimeoutException extends AppException {
  TimeoutException(String message) : super(message);
}

/// Not Found exception - Resource not found (404)
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 404);
}

/// Unauthorized exception - Authentication required (401)
class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, 401);
}

/// Forbidden exception - Insufficient permissions (403)
class ForbiddenException extends AppException {
  ForbiddenException(String message) : super(message, 403);
}

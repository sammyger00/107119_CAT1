import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Handles errors and converts exceptions to failures
class ErrorHandler {
  /// Convert Dio errors to appropriate exceptions
  static Exception handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timeout. Please try again.');

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badCertificate:
        return NetworkException('Certificate verification failed.');

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          'An unexpected error occurred. Please try again.',
        );
    }
  }

  /// Handle HTTP response errors based on status code
  static Exception _handleResponseError(Response? response) {
    if (response == null) {
      return ServerException('Unknown server error occurred.');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    String message = 'An error occurred.';

    // Extract error message from response
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;

      // Handle validation errors (422)
      if (statusCode == 422 && data['errors'] != null) {
        return ValidationException(
          message,
          data['errors'] as Map<String, dynamic>?,
        );
      }
    }

    // Handle specific status codes
    switch (statusCode) {
      case 401:
        return UnauthorizedException(
          message.isNotEmpty ? message : 'Authentication required.',
        );

      case 403:
        return ForbiddenException(
          message.isNotEmpty ? message : 'Access forbidden.',
        );

      case 404:
        return NotFoundException(
          message.isNotEmpty ? message : 'Resource not found.',
        );

      case 422:
        return ValidationException(message);

      case 500:
      case 502:
      case 503:
        return ServerException(
          'Server error. Please try again later.',
          statusCode,
        );

      default:
        return ServerException(message, statusCode);
    }
  }

  /// Convert exceptions to failures for domain layer
  static Failure exceptionToFailure(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message, exception.statusCode);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message, exception.statusCode);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, exception.errors);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(exception.message);
    } else if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    } else if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    } else if (exception is ForbiddenException) {
      return ForbiddenFailure(exception.message);
    } else {
      return GenericFailure(exception.toString());
    }
  }

  /// Get user-friendly error message from failure
  static String getErrorMessage(Failure failure) {
    if (failure is ValidationFailure && failure.errors != null) {
      // Combine all validation errors into one message
      final errors = failure.errors!;
      final messages = errors.values
          .map((e) => e is List ? e.join(', ') : e.toString())
          .join('\n');
      return messages.isNotEmpty ? messages : failure.message;
    }
    return failure.message;
  }
}

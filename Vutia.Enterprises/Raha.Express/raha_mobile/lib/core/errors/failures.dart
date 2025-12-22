import 'package:equatable/equatable.dart';

/// Base failure class for error handling in domain layer
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => message;
}

/// Server failure - API errors
class ServerFailure extends Failure {
  const ServerFailure(String message, [int? statusCode])
      : super(message, statusCode);
}

/// Cache failure - Local storage errors
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Network failure - Connection errors
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Authentication failure - Auth errors
class AuthFailure extends Failure {
  const AuthFailure(String message, [int? statusCode])
      : super(message, statusCode);
}

/// Validation failure - Input validation errors
class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure(String message, [this.errors]) : super(message);

  @override
  List<Object?> get props => [message, errors];
}

/// Timeout failure - Request timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message) : super(message);
}

/// Not Found failure - Resource not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message, 404);
}

/// Unauthorized failure - Authentication required
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message) : super(message, 401);
}

/// Forbidden failure - Insufficient permissions
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(String message) : super(message, 403);
}

/// Generic failure - Unknown errors
class GenericFailure extends Failure {
  const GenericFailure(String message) : super(message);
}

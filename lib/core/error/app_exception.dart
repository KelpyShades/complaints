/// Base exception for all app-level errors.
///
/// Carries a user-friendly [message] and an optional raw [error] + [stackTrace]
/// for logging purposes.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.error,
    this.stackTrace,
  });

  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// Authentication-related errors (login, signup, session).
final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

/// Network / connectivity errors.
final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

/// Database query / mutation errors.
final class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

/// Form or input validation errors.
final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

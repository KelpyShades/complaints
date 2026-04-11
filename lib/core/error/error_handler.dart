import 'dart:io';

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'app_exception.dart';

/// Central error handler that maps raw exceptions into [AppException]s
/// and logs them.
///
/// Every repository method should wrap its body in a try/catch and call
/// [ErrorHandler.handle] in the catch block.
abstract final class ErrorHandler {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: 2, errorMethodCount: 5),
  );

  /// Converts a raw [error] into an appropriate [AppException] and logs it.
  static AppException handle(Object error, [StackTrace? stackTrace]) {
    _logger.e('Caught error', error: error, stackTrace: stackTrace);

    if (error is AppException) return error;

    if (error is supabase.AuthException) {
      return AuthException(
        message: _mapAuthMessage(error.message),
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (error is supabase.PostgrestException) {
      return DatabaseException(
        message: _mapPostgrestMessage(error.message),
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (error is SocketException) {
      return NetworkException(
        message: 'No internet connection. Please check your network.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return DatabaseException(
        message: 'Invalid data format received.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return DatabaseException(
      message: 'Something went wrong. Please try again.',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _mapAuthMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (lower.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email address.';
    }
    if (lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment.';
    }
    return 'Authentication error. Please try again.';
  }

  static String _mapPostgrestMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('violates foreign key')) {
      return 'Referenced record does not exist.';
    }
    if (lower.contains('duplicate key')) {
      return 'This record already exists.';
    }
    if (lower.contains('permission denied') || lower.contains('rls')) {
      return 'You do not have permission to perform this action.';
    }
    return 'A database error occurred. Please try again.';
  }
}

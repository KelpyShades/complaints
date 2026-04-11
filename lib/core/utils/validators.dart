/// Pure validation functions for form fields.
///
/// Each returns `null` when valid, or an error message string when invalid.
abstract final class Validators {
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, 'Email');
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value, 'Password');
    if (requiredError != null) return requiredError;

    if (value!.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    final requiredError = required(value, 'Confirm password');
    if (requiredError != null) return requiredError;

    if (value != original) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Creates a min-length validator with the given [min].
  static String? Function(String?) minLength(int min,
      [String fieldName = 'This field']) {
    return (String? value) {
      final requiredError = required(value, fieldName);
      if (requiredError != null) return requiredError;

      if (value!.trim().length < min) {
        return '$fieldName must be at least $min characters.';
      }
      return null;
    };
  }
}

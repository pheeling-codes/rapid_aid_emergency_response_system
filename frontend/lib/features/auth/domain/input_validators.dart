/// Input validation and sanitization utilities for the auth layer.
/// Protects the persistent data layer from injection and malformed data.
class InputValidators {
  InputValidators._();

  /// RFC-compliant email regex.
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  /// Minimum 8 characters, at least 1 letter and 1 digit.
  static final _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d).{8,}$',
  );

  /// Validates an email address against RFC-compliant regex.
  /// Returns `null` if valid, or an error message string.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates a password: min 8 chars, at least 1 letter + 1 digit.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must contain at least one letter and one number.';
    }
    return null;
  }

  /// Validates a full name: non-empty, minimum 2 characters.
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  /// Trims whitespace and strips dangerous HTML/script tags
  /// to prevent injection attacks before transmission.
  static String sanitize(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Strip HTML tags
        .replaceAll(RegExp(r'[<>&"'']'), ''); // Strip dangerous chars
  }
}

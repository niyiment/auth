class ValidationUtils {
  // Reguired validation
  static String? requiredFieldValidator(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Email validation
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? passwordValidator(String? value, {int minLength = 8}) {
    if (value == null || value.trim().isEmpty)  {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at lease one uppercase letter';
    }
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    //  Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // Confirm password validation
  static String? confirmPasswordValidator(String? value, String? password) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Phone number validation
  static String? phoneNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final cleanedValue = value.replaceAll(RegExp(r'[^\d+]'), '');
    final internationalPhoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    if (!internationalPhoneRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid international phone number';
    }
    return null;
  }

  // Name validation
  static String? nameValidator(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }
}

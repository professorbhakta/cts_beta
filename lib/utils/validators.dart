/// Utility class for form input validation
class Validators {
  /// Validates mobile number (10 digits)
  static String? mobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    
    // Remove any spaces, dashes, or other characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleaned.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleaned)) {
      return 'Enter valid 10-digit mobile number';
    }
    
    // Check if it starts with valid digits (typically 6-9 in India)
    if (!RegExp(r'^[6-9]').hasMatch(cleaned)) {
      return 'Mobile number should start with 6, 7, 8, or 9';
    }
    
    return null;
  }

  /// Validates email address
  static String? email(String? value, {bool isRequired = true}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Email is required' : null;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  /// Validates required field
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    return null;
  }

  /// Validates password with strength requirements
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  /// Validates name (alphabets and spaces only)
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$fieldName should contain only letters and spaces';
    }
    
    return null;
  }

  /// Validates numeric input
  static String? numeric(String? value, {String fieldName = 'Field', bool isRequired = true}) {
    if (value == null || value.isEmpty) {
      return isRequired ? '$fieldName is required' : null;
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return '$fieldName must be a number';
    }
    
    return null;
  }

  /// Validates positive number
  static String? positiveNumber(String? value, {String fieldName = 'Field', bool isRequired = true}) {
    final numericError = numeric(value, fieldName: fieldName, isRequired: isRequired);
    if (numericError != null) return numericError;
    
    if (value != null && value.isNotEmpty) {
      final num = int.tryParse(value.trim());
      if (num == null || num <= 0) {
        return '$fieldName must be a positive number';
      }
    }
    
    return null;
  }

  /// Validates registration number (alphanumeric)
  static String? registrationNumber(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Registration number is required';
    }
    
    if (value.trim().length < 3) {
      return 'Registration number must be at least 3 characters';
    }
    
    // Allow alphanumeric and common vehicle registration formats
    if (!RegExp(r'^[A-Z0-9\s\-]+$', caseSensitive: false).hasMatch(value.trim())) {
      return 'Enter a valid registration number';
    }
    
    return null;
  }

  /// Validates capacity (positive number with reasonable range)
  static String? capacity(String? value) {
    final positiveError = positiveNumber(value, fieldName: 'Capacity');
    if (positiveError != null) return positiveError;
    
    if (value != null && value.isNotEmpty) {
      final num = int.tryParse(value.trim());
      if (num != null && (num < 1 || num > 100)) {
        return 'Capacity must be between 1 and 100';
      }
    }
    
    return null;
  }

  /// Validates distance/kilometers (positive number)
  static String? distance(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Distance is required';
    }
    
    final num = double.tryParse(value.trim());
    if (num == null || num <= 0) {
      return 'Distance must be a positive number';
    }
    
    if (num > 10000) {
      return 'Distance seems too large. Please verify';
    }
    
    return null;
  }

  /// Validates date (not in past for start dates)
  static String? date(DateTime? value, {bool allowPast = false, String fieldName = 'Date'}) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (!allowPast && value.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return '$fieldName cannot be in the past';
    }
    
    return null;
  }

  /// Validates time range (start time before end time)
  static String? timeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) {
      return null; // Let individual time validators handle null
    }
    
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return 'End time must be after start time';
    }
    
    return null;
  }

  /// Validates college name
  static String? collegeName(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'College name is required';
    }
    
    if (value.trim().length < 2) {
      return 'College name must be at least 2 characters';
    }
    
    return null;
  }

  /// Validates address
  static String? address(String? value, {bool isRequired = true}) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return isRequired ? 'Address is required' : null;
    }
    
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    
    return null;
  }

  /// Validates pickup point name
  static String? pickupPointName(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Pickup point name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Pickup point name must be at least 2 characters';
    }
    
    return null;
  }

  /// Validates route name
  static String? routeName(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Route name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Route name must be at least 2 characters';
    }
    
    return null;
  }

  /// Validates batch name
  static String? batchName(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Batch name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Batch name must be at least 2 characters';
    }
    
    return null;
  }

  /// Validates in-line number (for pickup points)
  static String? inLineNumber(String? value) {
    final positiveError = positiveNumber(value, fieldName: 'In-line number');
    if (positiveError != null) return positiveError;
    
    if (value != null && value.isNotEmpty) {
      final num = int.tryParse(value.trim());
      if (num != null && num > 1000) {
        return 'In-line number seems too large';
      }
    }
    
    return null;
  }
}








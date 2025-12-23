/// Utility class for phone number formatting
/// Converts Kenyan phone numbers to international format (254XXXXXXXXX)
class PhoneFormatter {
  /// Normalize Kenyan phone number to 254XXXXXXXXX format
  ///
  /// Handles the following input formats:
  /// - 0712345678 → 254712345678
  /// - +254712345678 → 254712345678
  /// - 254712345678 → 254712345678
  /// - 712345678 → 254712345678
  ///
  /// Returns null if the phone number is invalid
  static String? normalize(String? phone) {
    if (phone == null || phone.isEmpty) return null;

    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading zeros
    cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');

    // Handle different formats
    if (cleaned.startsWith('254')) {
      // Already in correct format
      return cleaned;
    } else if (cleaned.startsWith('7') || cleaned.startsWith('1')) {
      // Local format (7XX or 1XX) - add country code
      return '254$cleaned';
    } else {
      // Invalid format
      return null;
    }
  }

  /// Validate Kenyan phone number format
  ///
  /// Accepts:
  /// - 0712345678 (10 digits starting with 0)
  /// - 712345678 (9 digits starting with 7 or 1)
  /// - 254712345678 (12 digits starting with 254)
  /// - +254712345678 (with + prefix)
  static bool isValid(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Check length and format
    if (cleaned.length == 10 && cleaned.startsWith('0')) {
      // 0712345678 format
      return cleaned.startsWith('07') || cleaned.startsWith('01');
    } else if (cleaned.length == 9) {
      // 712345678 format
      return cleaned.startsWith('7') || cleaned.startsWith('1');
    } else if (cleaned.length == 12 && cleaned.startsWith('254')) {
      // 254712345678 format
      return cleaned.startsWith('2547') || cleaned.startsWith('2541');
    }

    return false;
  }

  /// Format phone number for display
  ///
  /// Converts to readable format:
  /// 254712345678 → +254 712 345 678
  /// 0712345678 → 0712 345 678
  static String? formatForDisplay(String? phone) {
    if (phone == null || phone.isEmpty) return null;

    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.startsWith('254') && cleaned.length == 12) {
      // International format
      return '+254 ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    } else if (cleaned.startsWith('0') && cleaned.length == 10) {
      // Local format
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    } else if (cleaned.length == 9) {
      // Without leading zero
      return '0${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }

    return phone; // Return original if format not recognized
  }

  /// Convert international format to local format
  /// 254712345678 → 0712345678
  static String? toLocalFormat(String? phone) {
    final normalized = normalize(phone);
    if (normalized == null || !normalized.startsWith('254')) return phone;

    return '0${normalized.substring(3)}';
  }

  /// Extract country code
  /// Returns '254' for Kenyan numbers, null otherwise
  static String? getCountryCode(String? phone) {
    final normalized = normalize(phone);
    if (normalized == null) return null;

    if (normalized.startsWith('254')) return '254';
    return null;
  }
}

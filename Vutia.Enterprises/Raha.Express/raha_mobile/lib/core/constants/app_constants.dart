class AppConstants {
  // App Info
  static const String appName = 'Raha Express';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Parcel Status
  static const String statusSent = 'Sent';
  static const String statusLoaded = 'Loaded';
  static const String statusOffloaded = 'Offloaded';
  static const String statusReceived = 'Received';
  static const String statusIssued = 'Issued';

  // Payment Methods
  static const String paymentCash = 'Cash';
  static const String paymentMpesa = 'M-Pesa';
  static const String paymentFamilyBank = 'Family Bank';
  static const String paymentNotPaid = 'Not Paid';
  static const String paymentCashOnIssue = 'Cash on Issue';
  static const String paymentMpesaOnIssue = 'M-Pesa on Issue';
  static const String paymentFamilyBankOnIssue = 'Family Bank on Issue';

  // Offload Modes
  static const String offloadModeTransit = 'Transit';
  static const String offloadModeFinal = 'Final';

  // Manifest Status
  static const String manifestStatusActive = 'Active';
  static const String manifestStatusCompleted = 'Completed';
  static const String manifestStatusCancelled = 'Cancelled';

  // Phone Number Format
  static const String kenyaPhonePrefix = '254';
  static const int kenyaPhoneLength = 12; // 254XXXXXXXXX
}

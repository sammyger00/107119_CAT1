class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://dev.rahaexpress.co.ke/api/v1';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String user = '/auth/user';
  static const String refresh = '/auth/refresh';

  // Parcel endpoints
  static const String parcels = '/parcels';
  static String parcelById(int id) => '/parcels/$id';
  static String trackParcel(String number) => '/parcels/track/$number';
  static String loadParcel(int id) => '/parcels/$id/load';
  static String offloadParcel(int id) => '/parcels/$id/offload';
  static String receiveParcel(int id) => '/parcels/$id/receive';
  static String issueParcel(int id) => '/parcels/$id/issue';

  // Station endpoints
  static const String stations = '/stations';
  static String stationById(int id) => '/stations/$id';

  // Payment endpoints
  static const String initiateMpesa = '/payments/mpesa/initiate';
  static const String initiateFamilyBank = '/payments/family-bank/initiate';
  static String paymentStatus(String transactionId) =>
      '/payments/$transactionId/status';

  // Vehicle Manifest endpoints
  static const String manifests = '/manifests';
  static String manifestById(int id) => '/manifests/$id';
  static String updateManifestStatus(int id) => '/manifests/$id/status';
  static const String vehicles = '/vehicles';
}

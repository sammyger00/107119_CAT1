import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

/// Service for payment operations
class PaymentService {
  final DioClient _dioClient = DioClient();

  /// Format phone number to 254 format
  String formatPhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (phone.startsWith('0')) {
      phone = '254${phone.substring(1)}';
    } else if (phone.startsWith('+254')) {
      phone = phone.substring(1);
    } else if (!phone.startsWith('254')) {
      phone = '254$phone';
    }

    return phone;
  }

  /// Initiate M-Pesa STK Push payment
  Future<Map<String, dynamic>> initiateMpesa({
    required int parcelId,
    required String phoneNumber,
  }) async {
    final formattedPhone = formatPhoneNumber(phoneNumber);

    final response = await _dioClient.post(
      ApiConstants.initiateMpesa,
      data: {
        'parcel_id': parcelId,
        'phone_number': formattedPhone,
      },
    );

    return response.data;
  }

  /// Initiate Family Bank payment
  Future<Map<String, dynamic>> initiateFamilyBank({
    required int parcelId,
    required String phoneNumber,
  }) async {
    final formattedPhone = formatPhoneNumber(phoneNumber);

    final response = await _dioClient.post(
      ApiConstants.initiateFamilyBank,
      data: {
        'parcel_id': parcelId,
        'phone_number': formattedPhone,
      },
    );

    return response.data;
  }

  /// Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    final response = await _dioClient.get(
      ApiConstants.paymentStatus(transactionId),
    );

    return response.data;
  }
}

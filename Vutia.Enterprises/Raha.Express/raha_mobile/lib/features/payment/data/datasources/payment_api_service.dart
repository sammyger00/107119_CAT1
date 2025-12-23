import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/mpesa_response.dart';
import '../models/family_bank_response.dart';
import '../models/payment_status_response.dart';

part 'payment_api_service.g.dart';

@RestApi()
abstract class PaymentApiService {
  factory PaymentApiService(Dio dio, {String baseUrl}) = _PaymentApiService;

  /// Initiate M-Pesa STK Push
  ///
  /// Sends STK push to customer's phone for payment
  /// Requires: parcel_id, phone_number (254XXXXXXXXX format)
  @POST('/payments/mpesa/initiate')
  Future<MpesaSTKResponse> initiateMpesaPayment(
    @Body() Map<String, dynamic> body,
  );

  /// Initiate Family Bank STK Push
  ///
  /// Sends STK push to customer's phone for payment
  /// Requires: parcel_id, phone_number (254XXXXXXXXX format)
  @POST('/payments/family-bank/initiate')
  Future<FamilyBankSTKResponse> initiateFamilyBankPayment(
    @Body() Map<String, dynamic> body,
  );

  /// Check payment status
  ///
  /// Polls the backend to check if payment was completed
  /// Used after initiating STK push
  @GET('/payments/{transactionId}/status')
  Future<PaymentStatusResponse> checkPaymentStatus(
    @Path('transactionId') String transactionId,
  );
}

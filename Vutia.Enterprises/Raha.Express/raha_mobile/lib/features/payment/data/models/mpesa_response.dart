import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'mpesa_response.g.dart';

/// M-Pesa STK Push response model
@JsonSerializable()
class MpesaSTKResponse extends Equatable {
  final bool success;
  final String? message;

  @JsonKey(name: 'checkout_request_id')
  final String? checkoutRequestId;

  @JsonKey(name: 'merchant_request_id')
  final String? merchantRequestId;

  @JsonKey(name: 'response_code')
  final String? responseCode;

  @JsonKey(name: 'response_description')
  final String? responseDescription;

  @JsonKey(name: 'customer_message')
  final String? customerMessage;

  const MpesaSTKResponse({
    required this.success,
    this.message,
    this.checkoutRequestId,
    this.merchantRequestId,
    this.responseCode,
    this.responseDescription,
    this.customerMessage,
  });

  factory MpesaSTKResponse.fromJson(Map<String, dynamic> json) =>
      _$MpesaSTKResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MpesaSTKResponseToJson(this);

  /// Check if STK push was successfully initiated
  /// Response code '0' means success
  bool get isSuccess => responseCode == '0' || success;

  /// Get user-friendly message
  String get displayMessage {
    if (customerMessage != null) return customerMessage!;
    if (message != null) return message!;
    if (responseDescription != null) return responseDescription!;
    return isSuccess
        ? 'Check your phone for M-Pesa prompt'
        : 'Failed to initiate payment';
  }

  @override
  List<Object?> get props => [
        success,
        checkoutRequestId,
        merchantRequestId,
        responseCode,
      ];
}

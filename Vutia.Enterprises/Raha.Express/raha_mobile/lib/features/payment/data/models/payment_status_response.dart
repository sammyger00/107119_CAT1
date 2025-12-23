import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'payment_status_response.g.dart';

/// Payment status check response
@JsonSerializable()
class PaymentStatusResponse extends Equatable {
  final bool success;
  final String? message;

  /// Payment type: 'M-Pesa' or 'Family Bank'
  final String? type;

  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  final double? amount;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  final DateTime? timestamp;

  @JsonKey(name: 'parcel_id')
  final int? parcelId;

  /// Payment status: 'Completed', 'Pending', 'Failed'
  final String? status;

  const PaymentStatusResponse({
    required this.success,
    this.message,
    this.type,
    this.transactionId,
    this.amount,
    this.phoneNumber,
    this.timestamp,
    this.parcelId,
    this.status,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentStatusResponseToJson(this);

  /// Check if payment is completed
  bool get isCompleted =>
      status?.toLowerCase() == 'completed' ||
      status?.toLowerCase() == 'success';

  /// Check if payment is pending
  bool get isPending => status?.toLowerCase() == 'pending';

  /// Check if payment failed
  bool get isFailed =>
      status?.toLowerCase() == 'failed' ||
      (!isCompleted && !isPending && status != null);

  /// Get user-friendly status message
  String get displayMessage {
    if (message != null) return message!;
    if (isCompleted) return 'Payment successful';
    if (isPending) return 'Payment pending';
    if (isFailed) return 'Payment failed';
    return 'Unknown payment status';
  }

  @override
  List<Object?> get props => [
        success,
        transactionId,
        amount,
        parcelId,
        status,
      ];
}

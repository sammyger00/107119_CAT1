import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'family_bank_response.g.dart';

/// Family Bank STK Push response model
@JsonSerializable()
class FamilyBankSTKResponse extends Equatable {
  final bool success;
  final String? message;

  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  final String? status;

  @JsonKey(name: 'response_code')
  final String? responseCode;

  @JsonKey(name: 'response_description')
  final String? responseDescription;

  const FamilyBankSTKResponse({
    required this.success,
    this.message,
    this.transactionId,
    this.status,
    this.responseCode,
    this.responseDescription,
  });

  factory FamilyBankSTKResponse.fromJson(Map<String, dynamic> json) =>
      _$FamilyBankSTKResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyBankSTKResponseToJson(this);

  /// Check if STK push was successfully initiated
  bool get isSuccess => success || status?.toLowerCase() == 'success';

  /// Get user-friendly message
  String get displayMessage {
    if (message != null) return message!;
    if (responseDescription != null) return responseDescription!;
    return isSuccess
        ? 'Check your phone for Family Bank prompt'
        : 'Failed to initiate payment';
  }

  @override
  List<Object?> get props => [
        success,
        transactionId,
        status,
        responseCode,
      ];
}

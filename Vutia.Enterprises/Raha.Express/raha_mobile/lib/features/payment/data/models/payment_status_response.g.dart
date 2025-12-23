// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentStatusResponse _$PaymentStatusResponseFromJson(
        Map<String, dynamic> json) =>
    PaymentStatusResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      type: json['type'] as String?,
      transactionId: json['transaction_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      parcelId: (json['parcel_id'] as num?)?.toInt(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$PaymentStatusResponseToJson(
        PaymentStatusResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'type': instance.type,
      'transaction_id': instance.transactionId,
      'amount': instance.amount,
      'phone_number': instance.phoneNumber,
      'timestamp': instance.timestamp?.toIso8601String(),
      'parcel_id': instance.parcelId,
      'status': instance.status,
    };

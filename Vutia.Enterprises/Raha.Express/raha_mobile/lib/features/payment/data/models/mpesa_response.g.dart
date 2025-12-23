// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mpesa_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MpesaSTKResponse _$MpesaSTKResponseFromJson(Map<String, dynamic> json) =>
    MpesaSTKResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      checkoutRequestId: json['checkout_request_id'] as String?,
      merchantRequestId: json['merchant_request_id'] as String?,
      responseCode: json['response_code'] as String?,
      responseDescription: json['response_description'] as String?,
      customerMessage: json['customer_message'] as String?,
    );

Map<String, dynamic> _$MpesaSTKResponseToJson(MpesaSTKResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'checkout_request_id': instance.checkoutRequestId,
      'merchant_request_id': instance.merchantRequestId,
      'response_code': instance.responseCode,
      'response_description': instance.responseDescription,
      'customer_message': instance.customerMessage,
    };

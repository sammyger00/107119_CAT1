// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_bank_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyBankSTKResponse _$FamilyBankSTKResponseFromJson(
        Map<String, dynamic> json) =>
    FamilyBankSTKResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      transactionId: json['transaction_id'] as String?,
      status: json['status'] as String?,
      responseCode: json['response_code'] as String?,
      responseDescription: json['response_description'] as String?,
    );

Map<String, dynamic> _$FamilyBankSTKResponseToJson(
        FamilyBankSTKResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'transaction_id': instance.transactionId,
      'status': instance.status,
      'response_code': instance.responseCode,
      'response_description': instance.responseDescription,
    };

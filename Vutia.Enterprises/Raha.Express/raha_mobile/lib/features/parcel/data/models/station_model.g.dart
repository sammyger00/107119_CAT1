// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StationModel _$StationModelFromJson(Map<String, dynamic> json) => StationModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      sendingPhoneNumber: json['sending_phone_number'] as String?,
      receivingPhoneNumber: json['receiving_phone_number'] as String?,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      receiptType: json['receipt_type'] as String?,
      stationType: json['station_type'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StationModelToJson(StationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sending_phone_number': instance.sendingPhoneNumber,
      'receiving_phone_number': instance.receivingPhoneNumber,
      'opening_time': instance.openingTime,
      'closing_time': instance.closingTime,
      'receipt_type': instance.receiptType,
      'station_type': instance.stationType,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

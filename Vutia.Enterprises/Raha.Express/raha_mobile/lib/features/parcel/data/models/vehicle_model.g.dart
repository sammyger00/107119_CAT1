// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      registrationNumber: json['registration_number'] as String,
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      vehicleType: json['vehicle_type'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'registration_number': instance.registrationNumber,
      'driver_name': instance.driverName,
      'driver_phone': instance.driverPhone,
      'user_id': instance.userId,
      'vehicle_type': instance.vehicleType,
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

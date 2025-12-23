import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel extends Equatable {
  final int id;
  final String name;

  @JsonKey(name: 'registration_number')
  final String registrationNumber;

  @JsonKey(name: 'driver_name')
  final String? driverName;

  @JsonKey(name: 'driver_phone')
  final String? driverPhone;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;

  final String? description;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const VehicleModel({
    required this.id,
    required this.name,
    required this.registrationNumber,
    this.driverName,
    this.driverPhone,
    this.userId,
    this.vehicleType,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        registrationNumber,
        driverName,
        driverPhone,
        userId,
        vehicleType,
      ];
}

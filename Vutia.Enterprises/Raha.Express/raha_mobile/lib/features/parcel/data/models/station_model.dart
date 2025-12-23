import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'station_model.g.dart';

@JsonSerializable()
class StationModel extends Equatable {
  final int id;
  final String name;

  @JsonKey(name: 'sending_phone_number')
  final String? sendingPhoneNumber;

  @JsonKey(name: 'receiving_phone_number')
  final String? receivingPhoneNumber;

  @JsonKey(name: 'opening_time')
  final String? openingTime;

  @JsonKey(name: 'closing_time')
  final String? closingTime;

  @JsonKey(name: 'receipt_type')
  final String? receiptType; // 'thermal' or 'SMS'

  @JsonKey(name: 'station_type')
  final String? stationType; // 'main' or 'branch'

  final String? notes;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const StationModel({
    required this.id,
    required this.name,
    this.sendingPhoneNumber,
    this.receivingPhoneNumber,
    this.openingTime,
    this.closingTime,
    this.receiptType,
    this.stationType,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) =>
      _$StationModelFromJson(json);

  Map<String, dynamic> toJson() => _$StationModelToJson(this);

  /// Check if station is currently open based on current time
  bool get isOpen {
    if (openingTime == null || closingTime == null) {
      return true; // Assume open if no times set
    }

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return currentTime.compareTo(openingTime!) >= 0 &&
        currentTime.compareTo(closingTime!) <= 0;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sendingPhoneNumber,
        receivingPhoneNumber,
        openingTime,
        closingTime,
        receiptType,
        stationType,
      ];
}

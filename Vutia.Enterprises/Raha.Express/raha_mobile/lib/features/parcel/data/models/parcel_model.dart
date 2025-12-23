import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'station_model.dart';
import 'vehicle_model.dart';

part 'parcel_model.g.dart';

/// Parcel status enum matching backend implementation
enum ParcelStatus {
  @JsonValue('Sent')
  sent,
  @JsonValue('Loaded')
  loaded,
  @JsonValue('Offloaded')
  offloaded,
  @JsonValue('Received')
  received,
  @JsonValue('Issued')
  issued,
}

/// Payment method enum matching backend implementation
enum PaymentMethod {
  @JsonValue('Cash')
  cash,
  @JsonValue('M-Pesa')
  mpesa,
  @JsonValue('Family Bank')
  familyBank,
  @JsonValue('Not Paid')
  notPaid,
  @JsonValue('Cash on Issue')
  cashOnIssue,
  @JsonValue('M-Pesa on Issue')
  mpesaOnIssue,
  @JsonValue('Family Bank on Issue')
  familyBankOnIssue,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.familyBank:
        return 'Family Bank';
      case PaymentMethod.notPaid:
        return 'Not Paid';
      case PaymentMethod.cashOnIssue:
        return 'Cash on Issue';
      case PaymentMethod.mpesaOnIssue:
        return 'M-Pesa on Issue';
      case PaymentMethod.familyBankOnIssue:
        return 'Family Bank on Issue';
    }
  }

  bool get requiresPhoneNumber {
    return this == PaymentMethod.mpesa ||
        this == PaymentMethod.mpesaOnIssue ||
        this == PaymentMethod.familyBank ||
        this == PaymentMethod.familyBankOnIssue;
  }

  bool get isMPesa {
    return this == PaymentMethod.mpesa || this == PaymentMethod.mpesaOnIssue;
  }

  bool get isFamilyBank {
    return this == PaymentMethod.familyBank ||
        this == PaymentMethod.familyBankOnIssue;
  }
}

/// Parcel model matching backend database schema
@JsonSerializable()
class ParcelModel extends Equatable {
  final int? id;

  @JsonKey(name: 'parcel_number')
  final String? parcelNumber;

  @JsonKey(name: 'sender_name')
  final String senderName;

  @JsonKey(name: 'sender_phone_number')
  final String senderPhoneNumber;

  @JsonKey(name: 'receiver_name')
  final String receiverName;

  @JsonKey(name: 'receiver_phone_number')
  final String receiverPhoneNumber;

  @JsonKey(name: 'origin_station_id')
  final int originStationId;

  @JsonKey(name: 'destination_station_id')
  final int destinationStationId;

  final double weight;
  final double value;
  final double cost;

  @JsonKey(name: 'payment_method')
  final PaymentMethod paymentMethod;

  @JsonKey(name: 'mpesa_phone_number')
  final String? mpesaPhoneNumber;

  @JsonKey(name: 'mpesa_transaction_id')
  final int? mpesaTransactionId;

  @JsonKey(name: 'family_bank_transaction_id')
  final int? familyBankTransactionId;

  final String description;
  final ParcelStatus status;

  // Status tracking fields
  @JsonKey(name: 'sent_by')
  final int? sentBy;

  @JsonKey(name: 'sent_at')
  final DateTime? sentAt;

  @JsonKey(name: 'loaded_by')
  final int? loadedBy;

  @JsonKey(name: 'loaded_at')
  final DateTime? loadedAt;

  @JsonKey(name: 'vehicle_id')
  final int? vehicleId;

  @JsonKey(name: 'offloaded_by')
  final int? offloadedBy;

  @JsonKey(name: 'offloaded_at')
  final DateTime? offloadedAt;

  @JsonKey(name: 'offloaded_mode')
  final String? offloadedMode; // 'Transit' or 'Final'

  @JsonKey(name: 'transit_id')
  final int? transitId;

  @JsonKey(name: 'received_by')
  final int? receivedBy;

  @JsonKey(name: 'received_at')
  final DateTime? receivedAt;

  @JsonKey(name: 'issued_by')
  final int? issuedBy;

  @JsonKey(name: 'issued_at')
  final DateTime? issuedAt;

  @JsonKey(name: 'recipient_name')
  final String? recipientName;

  @JsonKey(name: 'recipient_id')
  final String? recipientId;

  @JsonKey(name: 'delivery_note_id')
  final int? deliveryNoteId;

  // Relations
  @JsonKey(name: 'origin_station')
  final StationModel? originStation;

  @JsonKey(name: 'destination_station')
  final StationModel? destinationStation;

  final VehicleModel? vehicle;

  @JsonKey(name: 'transit_vehicle')
  final VehicleModel? transitVehicle;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ParcelModel({
    this.id,
    this.parcelNumber,
    required this.senderName,
    required this.senderPhoneNumber,
    required this.receiverName,
    required this.receiverPhoneNumber,
    required this.originStationId,
    required this.destinationStationId,
    required this.weight,
    required this.value,
    required this.cost,
    required this.paymentMethod,
    this.mpesaPhoneNumber,
    this.mpesaTransactionId,
    this.familyBankTransactionId,
    required this.description,
    this.status = ParcelStatus.sent,
    this.sentBy,
    this.sentAt,
    this.loadedBy,
    this.loadedAt,
    this.vehicleId,
    this.offloadedBy,
    this.offloadedAt,
    this.offloadedMode,
    this.transitId,
    this.receivedBy,
    this.receivedAt,
    this.issuedBy,
    this.issuedAt,
    this.recipientName,
    this.recipientId,
    this.deliveryNoteId,
    this.originStation,
    this.destinationStation,
    this.vehicle,
    this.transitVehicle,
    this.createdAt,
    this.updatedAt,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json) =>
      _$ParcelModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParcelModelToJson(this);

  /// Create JSON for API parcel creation (excludes read-only fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'sender_name': senderName,
      'sender_phone_number': senderPhoneNumber,
      'receiver_name': receiverName,
      'receiver_phone_number': receiverPhoneNumber,
      'origin_station_id': originStationId,
      'destination_station_id': destinationStationId,
      'weight': weight,
      'value': value,
      'cost': cost,
      'payment_method': _paymentMethodToString(paymentMethod),
      'description': description,
      if (mpesaPhoneNumber != null) 'mpesa_phone_number': mpesaPhoneNumber,
    };
  }

  String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.familyBank:
        return 'Family Bank';
      case PaymentMethod.notPaid:
        return 'Not Paid';
      case PaymentMethod.cashOnIssue:
        return 'Cash on Issue';
      case PaymentMethod.mpesaOnIssue:
        return 'M-Pesa on Issue';
      case PaymentMethod.familyBankOnIssue:
        return 'Family Bank on Issue';
    }
  }

  /// Copy with method for creating modified copies
  ParcelModel copyWith({
    int? id,
    String? parcelNumber,
    String? senderName,
    String? senderPhoneNumber,
    String? receiverName,
    String? receiverPhoneNumber,
    int? originStationId,
    int? destinationStationId,
    double? weight,
    double? value,
    double? cost,
    PaymentMethod? paymentMethod,
    String? mpesaPhoneNumber,
    int? mpesaTransactionId,
    int? familyBankTransactionId,
    String? description,
    ParcelStatus? status,
    int? vehicleId,
    String? offloadedMode,
    int? transitId,
    String? recipientName,
    String? recipientId,
  }) {
    return ParcelModel(
      id: id ?? this.id,
      parcelNumber: parcelNumber ?? this.parcelNumber,
      senderName: senderName ?? this.senderName,
      senderPhoneNumber: senderPhoneNumber ?? this.senderPhoneNumber,
      receiverName: receiverName ?? this.receiverName,
      receiverPhoneNumber: receiverPhoneNumber ?? this.receiverPhoneNumber,
      originStationId: originStationId ?? this.originStationId,
      destinationStationId: destinationStationId ?? this.destinationStationId,
      weight: weight ?? this.weight,
      value: value ?? this.value,
      cost: cost ?? this.cost,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      mpesaPhoneNumber: mpesaPhoneNumber ?? this.mpesaPhoneNumber,
      mpesaTransactionId: mpesaTransactionId ?? this.mpesaTransactionId,
      familyBankTransactionId:
          familyBankTransactionId ?? this.familyBankTransactionId,
      description: description ?? this.description,
      status: status ?? this.status,
      vehicleId: vehicleId ?? this.vehicleId,
      offloadedMode: offloadedMode ?? this.offloadedMode,
      transitId: transitId ?? this.transitId,
      recipientName: recipientName ?? this.recipientName,
      recipientId: recipientId ?? this.recipientId,
      sentBy: sentBy,
      sentAt: sentAt,
      loadedBy: loadedBy,
      loadedAt: loadedAt,
      offloadedBy: offloadedBy,
      offloadedAt: offloadedAt,
      receivedBy: receivedBy,
      receivedAt: receivedAt,
      issuedBy: issuedBy,
      issuedAt: issuedAt,
      deliveryNoteId: deliveryNoteId,
      originStation: originStation,
      destinationStation: destinationStation,
      vehicle: vehicle,
      transitVehicle: transitVehicle,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        parcelNumber,
        senderName,
        senderPhoneNumber,
        receiverName,
        receiverPhoneNumber,
        originStationId,
        destinationStationId,
        weight,
        value,
        cost,
        paymentMethod,
        description,
        status,
      ];
}

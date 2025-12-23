// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcelModel _$ParcelModelFromJson(Map<String, dynamic> json) => ParcelModel(
      id: (json['id'] as num?)?.toInt(),
      parcelNumber: json['parcel_number'] as String?,
      senderName: json['sender_name'] as String,
      senderPhoneNumber: json['sender_phone_number'] as String,
      receiverName: json['receiver_name'] as String,
      receiverPhoneNumber: json['receiver_phone_number'] as String,
      originStationId: (json['origin_station_id'] as num).toInt(),
      destinationStationId: (json['destination_station_id'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      paymentMethod:
          $enumDecode(_$PaymentMethodEnumMap, json['payment_method']),
      mpesaPhoneNumber: json['mpesa_phone_number'] as String?,
      mpesaTransactionId: (json['mpesa_transaction_id'] as num?)?.toInt(),
      familyBankTransactionId:
          (json['family_bank_transaction_id'] as num?)?.toInt(),
      description: json['description'] as String,
      status: $enumDecodeNullable(_$ParcelStatusEnumMap, json['status']) ??
          ParcelStatus.sent,
      sentBy: (json['sent_by'] as num?)?.toInt(),
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      loadedBy: (json['loaded_by'] as num?)?.toInt(),
      loadedAt: json['loaded_at'] == null
          ? null
          : DateTime.parse(json['loaded_at'] as String),
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      offloadedBy: (json['offloaded_by'] as num?)?.toInt(),
      offloadedAt: json['offloaded_at'] == null
          ? null
          : DateTime.parse(json['offloaded_at'] as String),
      offloadedMode: json['offloaded_mode'] as String?,
      transitId: (json['transit_id'] as num?)?.toInt(),
      receivedBy: (json['received_by'] as num?)?.toInt(),
      receivedAt: json['received_at'] == null
          ? null
          : DateTime.parse(json['received_at'] as String),
      issuedBy: (json['issued_by'] as num?)?.toInt(),
      issuedAt: json['issued_at'] == null
          ? null
          : DateTime.parse(json['issued_at'] as String),
      recipientName: json['recipient_name'] as String?,
      recipientId: json['recipient_id'] as String?,
      deliveryNoteId: (json['delivery_note_id'] as num?)?.toInt(),
      originStation: json['origin_station'] == null
          ? null
          : StationModel.fromJson(
              json['origin_station'] as Map<String, dynamic>),
      destinationStation: json['destination_station'] == null
          ? null
          : StationModel.fromJson(
              json['destination_station'] as Map<String, dynamic>),
      vehicle: json['vehicle'] == null
          ? null
          : VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      transitVehicle: json['transit_vehicle'] == null
          ? null
          : VehicleModel.fromJson(
              json['transit_vehicle'] as Map<String, dynamic>),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ParcelModelToJson(ParcelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parcel_number': instance.parcelNumber,
      'sender_name': instance.senderName,
      'sender_phone_number': instance.senderPhoneNumber,
      'receiver_name': instance.receiverName,
      'receiver_phone_number': instance.receiverPhoneNumber,
      'origin_station_id': instance.originStationId,
      'destination_station_id': instance.destinationStationId,
      'weight': instance.weight,
      'value': instance.value,
      'cost': instance.cost,
      'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'mpesa_phone_number': instance.mpesaPhoneNumber,
      'mpesa_transaction_id': instance.mpesaTransactionId,
      'family_bank_transaction_id': instance.familyBankTransactionId,
      'description': instance.description,
      'status': _$ParcelStatusEnumMap[instance.status]!,
      'sent_by': instance.sentBy,
      'sent_at': instance.sentAt?.toIso8601String(),
      'loaded_by': instance.loadedBy,
      'loaded_at': instance.loadedAt?.toIso8601String(),
      'vehicle_id': instance.vehicleId,
      'offloaded_by': instance.offloadedBy,
      'offloaded_at': instance.offloadedAt?.toIso8601String(),
      'offloaded_mode': instance.offloadedMode,
      'transit_id': instance.transitId,
      'received_by': instance.receivedBy,
      'received_at': instance.receivedAt?.toIso8601String(),
      'issued_by': instance.issuedBy,
      'issued_at': instance.issuedAt?.toIso8601String(),
      'recipient_name': instance.recipientName,
      'recipient_id': instance.recipientId,
      'delivery_note_id': instance.deliveryNoteId,
      'origin_station': instance.originStation,
      'destination_station': instance.destinationStation,
      'vehicle': instance.vehicle,
      'transit_vehicle': instance.transitVehicle,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'Cash',
  PaymentMethod.mpesa: 'M-Pesa',
  PaymentMethod.familyBank: 'Family Bank',
  PaymentMethod.notPaid: 'Not Paid',
  PaymentMethod.cashOnIssue: 'Cash on Issue',
  PaymentMethod.mpesaOnIssue: 'M-Pesa on Issue',
  PaymentMethod.familyBankOnIssue: 'Family Bank on Issue',
};

const _$ParcelStatusEnumMap = {
  ParcelStatus.sent: 'Sent',
  ParcelStatus.loaded: 'Loaded',
  ParcelStatus.offloaded: 'Offloaded',
  ParcelStatus.received: 'Received',
  ParcelStatus.issued: 'Issued',
};

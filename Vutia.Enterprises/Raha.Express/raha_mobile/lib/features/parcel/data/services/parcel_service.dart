import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

/// Service for parcel operations
class ParcelService {
  final DioClient _dioClient = DioClient();

  /// Get list of parcels with optional filters
  Future<Map<String, dynamic>> getParcels({
    String? status,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final response = await _dioClient.get(
      ApiConstants.parcels,
      queryParameters: queryParams,
    );

    return response.data;
  }

  /// Get single parcel details
  Future<Map<String, dynamic>> getParcel(int id) async {
    final response = await _dioClient.get(ApiConstants.parcelById(id));
    return response.data;
  }

  /// Track parcel by tracking number
  Future<Map<String, dynamic>> trackParcel(String trackingNumber) async {
    final response = await _dioClient.get(ApiConstants.trackParcel(trackingNumber));
    return response.data;
  }

  /// Create new parcel
  Future<Map<String, dynamic>> createParcel({
    required String senderName,
    required String senderPhoneNumber,
    required String receiverName,
    required String receiverPhoneNumber,
    required int originStationId,
    required int destinationStationId,
    required double weight,
    required double value,
    required double cost,
    required String paymentMethod,
    required String description,
    String? mpesaPhoneNumber,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.parcels,
      data: {
        'sender_name': senderName,
        'sender_phone_number': senderPhoneNumber,
        'receiver_name': receiverName,
        'receiver_phone_number': receiverPhoneNumber,
        'origin_station_id': originStationId,
        'destination_station_id': destinationStationId,
        'weight': weight,
        'value': value,
        'cost': cost,
        'payment_method': paymentMethod,
        'description': description,
        if (mpesaPhoneNumber != null) 'mpesa_phone_number': mpesaPhoneNumber,
      },
    );

    return response.data;
  }

  /// Load parcel onto vehicle
  Future<Map<String, dynamic>> loadParcel(int parcelId, int vehicleId) async {
    final response = await _dioClient.post(
      ApiConstants.loadParcel(parcelId),
      data: {'vehicle_id': vehicleId},
    );
    return response.data;
  }

  /// Offload parcel from vehicle
  Future<Map<String, dynamic>> offloadParcel(
    int parcelId, {
    required String offloadedMode,
    int? transitId,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.offloadParcel(parcelId),
      data: {
        'offloaded_mode': offloadedMode,
        if (transitId != null) 'transit_id': transitId,
      },
    );
    return response.data;
  }

  /// Receive parcel at destination station
  Future<Map<String, dynamic>> receiveParcel(int parcelId) async {
    final response = await _dioClient.post(ApiConstants.receiveParcel(parcelId));
    return response.data;
  }

  /// Issue parcel to recipient
  Future<Map<String, dynamic>> issueParcel(
    int parcelId, {
    required String recipientName,
    required String recipientId,
    String? recipientPhone,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.issueParcel(parcelId),
      data: {
        'recipient_name': recipientName,
        'recipient_id': recipientId,
        if (recipientPhone != null) 'recipient_phone': recipientPhone,
      },
    );
    return response.data;
  }
}

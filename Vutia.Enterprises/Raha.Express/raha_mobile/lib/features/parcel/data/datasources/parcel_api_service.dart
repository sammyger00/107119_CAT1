import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/parcel_model.dart';
import '../models/station_model.dart';
import '../models/vehicle_model.dart';

part 'parcel_api_service.g.dart';

@RestApi()
abstract class ParcelApiService {
  factory ParcelApiService(Dio dio, {String baseUrl}) = _ParcelApiService;

  /// Get list of parcels (station-scoped, paginated)
  @GET('/parcels')
  Future<ParcelListResponse> getParcels({
    @Query('page') int page = 1,
    @Query('per_page') int perPage = 20,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  /// Create new parcel
  @POST('/parcels')
  Future<ParcelResponse> createParcel(@Body() Map<String, dynamic> parcel);

  /// Get parcel by ID
  @GET('/parcels/{id}')
  Future<ParcelResponse> getParcelById(@Path('id') int id);

  /// Track parcel by parcel number
  @GET('/parcels/track/{parcelNumber}')
  Future<ParcelTrackingResponse> trackParcel(
    @Path('parcelNumber') String parcelNumber,
  );

  /// Load parcel onto vehicle
  @POST('/parcels/{id}/load')
  Future<ParcelResponse> loadParcel(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  /// Offload parcel from vehicle
  @POST('/parcels/{id}/offload')
  Future<ParcelResponse> offloadParcel(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  /// Receive parcel at destination station
  @POST('/parcels/{id}/receive')
  Future<ParcelResponse> receiveParcel(@Path('id') int id);

  /// Issue parcel to recipient
  @POST('/parcels/{id}/issue')
  Future<ParcelResponse> issueParcel(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  /// Get list of stations
  @GET('/stations')
  Future<StationListResponse> getStations();

  /// Get station by ID
  @GET('/stations/{id}')
  Future<StationResponse> getStationById(@Path('id') int id);

  /// Get list of vehicles
  @GET('/vehicles')
  Future<VehicleListResponse> getVehicles({
    @Query('available') bool? available,
  });

  /// Get vehicle by ID
  @GET('/vehicles/{id}')
  Future<VehicleResponse> getVehicleById(@Path('id') int id);
}

/// Response models for API

class ParcelResponse {
  final bool success;
  final String? message;
  final ParcelModel parcel;

  ParcelResponse({
    required this.success,
    this.message,
    required this.parcel,
  });

  factory ParcelResponse.fromJson(Map<String, dynamic> json) {
    return ParcelResponse(
      success: json['success'] ?? true,
      message: json['message'],
      parcel: ParcelModel.fromJson(json['parcel'] ?? json['data']),
    );
  }
}

class ParcelListResponse {
  final bool success;
  final List<ParcelModel> parcels;
  final PaginationMeta? meta;

  ParcelListResponse({
    required this.success,
    required this.parcels,
    this.meta,
  });

  factory ParcelListResponse.fromJson(Map<String, dynamic> json) {
    return ParcelListResponse(
      success: json['success'] ?? true,
      parcels: (json['parcels'] as List? ?? json['data'] as List? ?? [])
          .map((e) => ParcelModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'])
          : null,
    );
  }
}

class ParcelTrackingResponse {
  final bool success;
  final ParcelModel parcel;
  final List<StatusHistoryItem> statusHistory;
  final String currentStatus;

  ParcelTrackingResponse({
    required this.success,
    required this.parcel,
    required this.statusHistory,
    required this.currentStatus,
  });

  factory ParcelTrackingResponse.fromJson(Map<String, dynamic> json) {
    return ParcelTrackingResponse(
      success: json['success'] ?? true,
      parcel: ParcelModel.fromJson(json['parcel']),
      statusHistory: (json['status_history'] as List)
          .map((e) => StatusHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentStatus: json['current_status'],
    );
  }
}

class StatusHistoryItem {
  final String status;
  final DateTime timestamp;
  final String? userName;
  final String? stationName;
  final String? vehicleName;

  StatusHistoryItem({
    required this.status,
    required this.timestamp,
    this.userName,
    this.stationName,
    this.vehicleName,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      userName: json['user'],
      stationName: json['station'],
      vehicleName: json['vehicle'],
    );
  }
}

class StationResponse {
  final bool success;
  final StationModel station;

  StationResponse({
    required this.success,
    required this.station,
  });

  factory StationResponse.fromJson(Map<String, dynamic> json) {
    return StationResponse(
      success: json['success'] ?? true,
      station: StationModel.fromJson(json['station'] ?? json['data']),
    );
  }
}

class StationListResponse {
  final bool success;
  final List<StationModel> stations;

  StationListResponse({
    required this.success,
    required this.stations,
  });

  factory StationListResponse.fromJson(Map<String, dynamic> json) {
    return StationListResponse(
      success: json['success'] ?? true,
      stations: (json['stations'] as List? ?? json['data'] as List? ?? [])
          .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VehicleResponse {
  final bool success;
  final VehicleModel vehicle;

  VehicleResponse({
    required this.success,
    required this.vehicle,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      success: json['success'] ?? true,
      vehicle: VehicleModel.fromJson(json['vehicle'] ?? json['data']),
    );
  }
}

class VehicleListResponse {
  final bool success;
  final List<VehicleModel> vehicles;

  VehicleListResponse({
    required this.success,
    required this.vehicles,
  });

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) {
    return VehicleListResponse(
      success: json['success'] ?? true,
      vehicles: (json['vehicles'] as List? ?? json['data'] as List? ?? [])
          .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
      perPage: json['per_page'],
    );
  }

  bool get hasMore => currentPage < lastPage;
}

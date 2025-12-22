import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../constants/api_constants.dart';

part 'api_service.g.dart';

/// Retrofit API service for type-safe HTTP calls
@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Auth endpoints
  @POST(ApiConstants.login)
  Future<HttpResponse> login(@Body() Map<String, dynamic> credentials);

  @POST(ApiConstants.logout)
  Future<HttpResponse> logout();

  @GET(ApiConstants.user)
  Future<HttpResponse> getUser();

  @POST(ApiConstants.refresh)
  Future<HttpResponse> refreshToken();

  // Parcel endpoints
  @GET(ApiConstants.parcels)
  Future<HttpResponse> getParcels({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('search') String? search,
    @Query('status') String? status,
    @Query('station_id') int? stationId,
  });

  @POST(ApiConstants.parcels)
  Future<HttpResponse> createParcel(@Body() Map<String, dynamic> parcel);

  @GET('${ApiConstants.parcels}/{id}')
  Future<HttpResponse> getParcel(@Path('id') int id);

  @GET('${ApiConstants.parcels}/track/{parcelNumber}')
  Future<HttpResponse> trackParcel(@Path('parcelNumber') String parcelNumber);

  // Parcel Status endpoints
  @POST('${ApiConstants.parcels}/{id}/load')
  Future<HttpResponse> loadParcel(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  @POST('${ApiConstants.parcels}/{id}/offload')
  Future<HttpResponse> offloadParcel(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  @POST('${ApiConstants.parcels}/{id}/receive')
  Future<HttpResponse> receiveParcel(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  @POST('${ApiConstants.parcels}/{id}/issue')
  Future<HttpResponse> issueParcel(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  // Station endpoints
  @GET(ApiConstants.stations)
  Future<HttpResponse> getStations();

  @GET('${ApiConstants.stations}/{id}')
  Future<HttpResponse> getStation(@Path('id') int id);

  // Payment endpoints
  @POST(ApiConstants.initiateMpesa)
  Future<HttpResponse> initiateMpesa(@Body() Map<String, dynamic> data);

  @POST(ApiConstants.initiateFamilyBank)
  Future<HttpResponse> initiateFamilyBank(@Body() Map<String, dynamic> data);

  @GET('/payments/{transactionId}/status')
  Future<HttpResponse> getPaymentStatus(@Path('transactionId') String transactionId);

  // Vehicle Manifest endpoints
  @GET(ApiConstants.manifests)
  Future<HttpResponse> getManifests({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('status') String? status,
    @Query('vehicle_id') int? vehicleId,
  });

  @POST(ApiConstants.manifests)
  Future<HttpResponse> createManifest(@Body() Map<String, dynamic> manifest);

  @GET('${ApiConstants.manifests}/{id}')
  Future<HttpResponse> getManifest(@Path('id') int id);

  @PUT('${ApiConstants.manifests}/{id}/status')
  Future<HttpResponse> updateManifestStatus(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  @GET(ApiConstants.vehicles)
  Future<HttpResponse> getVehicles();
}

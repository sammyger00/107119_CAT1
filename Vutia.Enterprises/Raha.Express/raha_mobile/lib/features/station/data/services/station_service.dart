import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

/// Service for station operations
class StationService {
  final DioClient _dioClient = DioClient();

  /// Get list of all active stations
  Future<Map<String, dynamic>> getStations() async {
    final response = await _dioClient.get(ApiConstants.stations);
    return response.data;
  }

  /// Get station details
  Future<Map<String, dynamic>> getStation(int id) async {
    final response = await _dioClient.get(ApiConstants.stationById(id));
    return response.data;
  }

  /// Get list of available vehicles
  Future<Map<String, dynamic>> getVehicles() async {
    final response = await _dioClient.get(ApiConstants.vehicles);
    return response.data;
  }
}

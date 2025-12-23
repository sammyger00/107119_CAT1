import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

/// Model class to hold user data
class UserData {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool status;
  final int? stationId;
  final String? stationName;
  final bool isSuperAdmin;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.status,
    this.stationId,
    this.stationName,
    this.isSuperAdmin = false,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    final station = json['station'];
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      status: json['status'] == true || json['status'] == 1,
      stationId: station != null ? station['id'] : null,
      stationName: station != null ? station['name'] : null,
      isSuperAdmin: json['is_super_admin'] ?? false,
    );
  }
}

/// Service for managing user data in SharedPreferences
class UserStorage {
  static final UserStorage _instance = UserStorage._internal();
  factory UserStorage() => _instance;
  UserStorage._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save user data from API response
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await _preferences;

    await prefs.setInt(StorageConstants.userId, userData['id'] ?? 0);
    await prefs.setString(StorageConstants.userName, userData['name'] ?? '');
    await prefs.setString(StorageConstants.userEmail, userData['email'] ?? '');
    await prefs.setString(StorageConstants.userPhone, userData['phone_number'] ?? '');
    await prefs.setBool(StorageConstants.isSuperAdmin, userData['is_super_admin'] ?? false);

    // Save station info if available
    final station = userData['station'];
    if (station != null) {
      await prefs.setInt(StorageConstants.stationId, station['id'] ?? 0);
      await prefs.setString(StorageConstants.stationName, station['name'] ?? '');
    } else {
      await prefs.remove(StorageConstants.stationId);
      await prefs.remove(StorageConstants.stationName);
    }
  }

  /// Get stored user data
  Future<UserData?> getUser() async {
    final prefs = await _preferences;

    final userId = prefs.getInt(StorageConstants.userId);
    if (userId == null || userId == 0) {
      return null;
    }

    return UserData(
      id: userId,
      name: prefs.getString(StorageConstants.userName) ?? '',
      email: prefs.getString(StorageConstants.userEmail) ?? '',
      phoneNumber: prefs.getString(StorageConstants.userPhone) ?? '',
      status: true,
      stationId: prefs.getInt(StorageConstants.stationId),
      stationName: prefs.getString(StorageConstants.stationName),
      isSuperAdmin: prefs.getBool(StorageConstants.isSuperAdmin) ?? false,
    );
  }

  /// Get user name
  Future<String?> getUserName() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.userName);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.userEmail);
  }

  /// Get user phone
  Future<String?> getUserPhone() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.userPhone);
  }

  /// Check if user is super admin
  Future<bool> isSuperAdmin() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageConstants.isSuperAdmin) ?? false;
  }

  /// Clear all user data (for logout)
  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(StorageConstants.userId);
    await prefs.remove(StorageConstants.userName);
    await prefs.remove(StorageConstants.userEmail);
    await prefs.remove(StorageConstants.userPhone);
    await prefs.remove(StorageConstants.stationId);
    await prefs.remove(StorageConstants.stationName);
    await prefs.remove(StorageConstants.isSuperAdmin);
  }
}

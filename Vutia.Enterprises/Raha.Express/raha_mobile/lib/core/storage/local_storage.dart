import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

/// Service for managing local storage operations (non-sensitive data)
class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // User Data
  Future<void> saveUserId(int userId) async {
    final prefs = await _preferences;
    await prefs.setInt(StorageConstants.userId, userId);
  }

  Future<int?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getInt(StorageConstants.userId);
  }

  Future<void> saveUserName(String name) async {
    final prefs = await _preferences;
    await prefs.setString(StorageConstants.userName, name);
  }

  Future<String?> getUserName() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.userName);
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await _preferences;
    await prefs.setString(StorageConstants.userEmail, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.userEmail);
  }

  Future<void> saveUserPhone(String phone) async {
    final prefs = await _preferences;
    await prefs.setString(StorageConstants.userPhone, phone);
  }

  Future<String?> getUserPhone() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.userPhone);
  }

  // Station Data
  Future<void> saveStationId(int stationId) async {
    final prefs = await _preferences;
    await prefs.setInt(StorageConstants.stationId, stationId);
  }

  Future<int?> getStationId() async {
    final prefs = await _preferences;
    return prefs.getInt(StorageConstants.stationId);
  }

  Future<void> saveStationName(String name) async {
    final prefs = await _preferences;
    await prefs.setString(StorageConstants.stationName, name);
  }

  Future<String?> getStationName() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.stationName);
  }

  Future<void> saveIsSuperAdmin(bool isSuperAdmin) async {
    final prefs = await _preferences;
    await prefs.setBool(StorageConstants.isSuperAdmin, isSuperAdmin);
  }

  Future<bool> getIsSuperAdmin() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageConstants.isSuperAdmin) ?? false;
  }

  // Device Info
  Future<void> saveDeviceName(String deviceName) async {
    final prefs = await _preferences;
    await prefs.setString(StorageConstants.deviceName, deviceName);
  }

  Future<String?> getDeviceName() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.deviceName);
  }

  // App Preferences
  Future<void> saveIsFirstLaunch(bool isFirstLaunch) async {
    final prefs = await _preferences;
    await prefs.setBool(StorageConstants.isFirstLaunch, isFirstLaunch);
  }

  Future<bool> getIsFirstLaunch() async {
    final prefs = await _preferences;
    return prefs.getBool(StorageConstants.isFirstLaunch) ?? true;
  }

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await _preferences;
    await prefs.setString(StorageConstants.themeMode, themeMode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.themeMode);
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await _preferences;
    await prefs.setString(StorageConstants.language, language);
  }

  Future<String?> getLanguage() async {
    final prefs = await _preferences;
    return prefs.getString(StorageConstants.language);
  }

  /// Clear all local storage
  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  /// Clear user session data (keep app preferences)
  Future<void> clearSession() async {
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

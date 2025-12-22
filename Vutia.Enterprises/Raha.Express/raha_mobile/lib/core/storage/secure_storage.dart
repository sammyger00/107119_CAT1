import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_constants.dart';

/// Service for managing secure storage operations (tokens and sensitive data)
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageConstants.authToken, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: StorageConstants.authToken);
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _storage.delete(key: StorageConstants.authToken);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageConstants.refreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageConstants.refreshToken);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: StorageConstants.refreshToken);
  }

  /// Clear all secure storage
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// Check if user is authenticated (has token)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

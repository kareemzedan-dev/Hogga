import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  AppSecureStorage._internal();
  static final AppSecureStorage _instance = AppSecureStorage._internal();
  factory AppSecureStorage() => _instance;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Helper methods for Token
  static const String _tokenKey = 'secure_token';

  Future<void> saveToken(String token) async {
    await write(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return await read(_tokenKey);
  }

  Future<void> deleteToken() async {
    await delete(_tokenKey);
  }
}

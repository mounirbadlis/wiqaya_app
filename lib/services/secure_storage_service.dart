import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  
  static final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Save a value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read a value
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete a value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Delete all keys
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

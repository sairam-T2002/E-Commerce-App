import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserDataHelper {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>?> getUserData(String key) async {
    String? jsonString = await _storage.read(key: key);
    return jsonString != null ? jsonDecode(jsonString) : null;
  }

  static Future<void> storeUserData(
      String key, Map<String, dynamic> data) async {
    String jsonString = jsonEncode(data);
    await _storage.write(key: key, value: jsonString);
  }

  static Future<void> deleteUserData(String key) async {
    await _storage.delete(key: key);
  }
}

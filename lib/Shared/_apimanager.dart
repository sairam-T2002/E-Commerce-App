import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

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
}

const String baseUrl = 'http://10.0.5.38:5085/';

Future<Map<String, dynamic>?> getUserCredentials() async {
  return await UserDataHelper.getUserData('user_info_cred');
}

Future<Map<String, dynamic>?> fetchApiGET(
    String endpoint, Map<String, String> params) async {
  Map<String, dynamic>? usr = await getUserCredentials();
  if (usr == null) {
    return null;
  }

  Uri url = Uri.parse(baseUrl + endpoint).replace(queryParameters: params);

  try {
    http.Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${usr['accessToken']}',
      },
    );

    if (response.statusCode == 401) {
      return await appRefreshToken(usr['accessToken'], usr['refreshToken'],
          () => fetchApiGET(endpoint, params));
    }

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  } catch (error) {
    rethrow;
  }
}

Future<Map<String, dynamic>?> fetchApiPOST(
    String endpoint, Map<String, dynamic> body,
    {bool isLogin = false}) async {
  Map<String, dynamic>? usr = await getUserCredentials();
  if (usr == null && !isLogin) {
    return null;
  }

  Uri url = Uri.parse(baseUrl + endpoint);

  try {
    http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${usr?['accessToken'] ?? ''}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      return await appRefreshToken(usr!['accessToken'], usr['refreshToken'],
          () => fetchApiPOST(endpoint, body, isLogin: isLogin));
    }

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  } catch (error) {
    rethrow;
  }
}

Future<Map<String, dynamic>?> appRefreshToken(
    String accessToken,
    String refreshToken,
    Future<Map<String, dynamic>?> Function() callback) async {
  try {
    final response = await fetchApiPOST('api/Auth/Refresh',
        {'AccessToken': accessToken, 'RefreshToken': refreshToken});

    if (response == null) {
      return null;
    }

    final data = response;

    Map<String, dynamic>? usr = await getUserCredentials();
    if (usr != null) {
      await UserDataHelper.storeUserData('user_info_cred', {
        ...usr,
        'accessToken': data['AccessToken'],
        'refreshToken': data['RefreshToken']
      });
      return await callback();
    } else {
      throw Exception('User credentials could not be retrieved');
    }
  } catch (exception) {
    rethrow;
  }
}

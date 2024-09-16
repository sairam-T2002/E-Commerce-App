import 'dart:convert';
import 'package:http/http.dart' as http;
import '_localstorage.dart';
import '../config.dart';

const String baseUrl = Config.apiUrl;
const int maxRetries = 2;

Future<Map<String, dynamic>?> getUserCredentials() async {
  return await UserDataHelper.getUserData(LocalStorageKeys.userCred);
}

Future<Map<String, dynamic>?> fetchApiGET(
    String endpoint, Map<String, String>? params,
    {int retryCount = 0}) async {
  Map<String, dynamic>? usr = await getUserCredentials();
  if (usr == null) {
    return null;
  }

  Uri url;
  if (params != null) {
    url = Uri.parse(baseUrl + endpoint).replace(queryParameters: params);
  } else {
    url = Uri.parse(baseUrl + endpoint);
  }

  try {
    http.Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${usr['accessToken']}',
      },
    );

    if (response.statusCode == 401 && retryCount < maxRetries) {
      return await appRefreshToken(usr['accessToken'], usr['refreshToken'],
          () => fetchApiGET(endpoint, params, retryCount: retryCount + 1));
    }

    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  } catch (error) {
    rethrow;
  }
}

Future<Map<String, dynamic>?> fetchApiPOST(
    String endpoint, Map<String, dynamic> body,
    {bool isLogin = false, int retryCount = 0}) async {
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

    if (response.statusCode == 401 && retryCount < maxRetries) {
      return await appRefreshToken(
          usr!['accessToken'],
          usr['refreshToken'],
          () => fetchApiPOST(endpoint, body,
              isLogin: isLogin, retryCount: retryCount + 1));
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
      Map<String, String> temp = {
        'username': usr['username'],
        'accessToken': data['accessToken'],
        'refreshToken': data['refreshToken']
      };
      await UserDataHelper.storeUserData(LocalStorageKeys.userCred, temp);
      return await callback();
    } else {
      throw Exception('User credentials could not be retrieved');
    }
  } catch (exception) {
    rethrow;
  }
}

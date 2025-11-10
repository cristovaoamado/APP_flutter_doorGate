import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class HttpService {
  static String? _authToken;

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static String? get authToken => _authToken;
  static bool get isAuthenticated => _authToken != null;

  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  static Future<http.Response> get(
    String url, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiConfig.requestTimeout);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> post(
    String url,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> put(
    String url,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> delete(
    String url, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiConfig.requestTimeout);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

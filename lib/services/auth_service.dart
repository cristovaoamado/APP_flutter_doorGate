import 'dart:convert';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import 'http_service.dart';

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthService {
  Future<LoginResponse> register(
      String name, String email, String password) async {
    try {
      print('🔵 Tentando registar: $email');
      print('🔵 URL: ${ApiConfig.register}');
      
      final response = await HttpService.post(
        ApiConfig.register,
        {
          'name': name,
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔵 JSON parseado: $jsonData');
        
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonData,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          final loginResponse = LoginResponse.fromJson(apiResponse.data!);
          await HttpService.setAuthToken(loginResponse.token);
          print('✅ Registo bem sucedido!');
          return loginResponse;
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          throw Exception(apiResponse.message);
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        final jsonData = jsonDecode(response.body);
        print('❌ Erro body: $jsonData');
        throw Exception(jsonData['message'] ?? 'Erro ao registar');
      }
    } catch (e) {
      print('❌ ERRO CATCH: $e');
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    try {
      print('🔵 Tentando login: $email');
      print('🔵 URL: ${ApiConfig.login}');
      
      final body = {
        'email': email,
        'password': password,
      };

      print('🔵 Request Body: $body');

      final response = await HttpService.post(
        ApiConfig.login,
        body,
        includeAuth: false,
      );

      print('🔵 Status Code: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔵 JSON parseado: $jsonData');
        
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonData,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          final loginResponse = LoginResponse.fromJson(apiResponse.data!);
          await HttpService.setAuthToken(loginResponse.token);
          print('✅ Login bem sucedido!');
          return loginResponse;
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          throw Exception(apiResponse.message);
        }
      } else if (response.statusCode == 401) {
        print('❌ Credenciais inválidas');
        throw Exception('Email ou password incorretos');
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        try {
          final jsonData = jsonDecode(response.body);
          print('❌ Erro body: $jsonData');
          throw Exception(jsonData['message'] ?? 'Erro ao fazer login');
        } catch (e) {
          print('❌ Erro ao parsear resposta de erro: $e');
          throw Exception('Erro ao fazer login');
        }
      }
    } catch (e) {
      print('❌ ERRO CATCH: $e');
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> logout() async {
    await HttpService.clearAuthToken();
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await HttpService.get(ApiConfig.currentUser);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonData,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return User.fromJson(apiResponse.data!);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateFcmToken(String fcmToken) async {
    try {
      final response = await HttpService.post(
        ApiConfig.updateFcmToken,
        {'fcmToken': fcmToken},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
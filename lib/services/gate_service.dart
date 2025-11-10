import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/gate_status.dart';
import '../models/gate_log.dart';
import '../models/api_response.dart';
import 'http_service.dart';

class GateService {
  Future<GateStatus?> getStatus() async {
    try {
      final response = await HttpService.get(ApiConfig.gateStatus);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonData,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return GateStatus.fromJson(apiResponse.data!);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting gate status: $e');
      }
      return null;
    }
  }

  Future<GateStatus?> controlGate(String action) async {
    try {
      final response = await HttpService.post(
        ApiConfig.gateControl,
        {'action': action},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonData,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return GateStatus.fromJson(apiResponse.data!);
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        final jsonData = jsonDecode(response.body);
        throw Exception(jsonData['message'] ?? 'Erro ao controlar portão');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<GateLog>> getHistory({int count = 50}) async {
    try {
      final response =
          await HttpService.get('${ApiConfig.gateHistory}?count=$count');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          jsonData,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((item) => GateLog.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting gate history: $e');
      }
      return [];
    }
  }
}

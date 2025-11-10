import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../config/api_config.dart';
import 'http_service.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stateStream => _stateController.stream;

  Future<void> connect() async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      return;
    }

    try {
      final token = HttpService.authToken;
      if (token == null) {
        throw Exception('No auth token available');
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            ApiConfig.signalRHub,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Registrar handlers - são MÉTODOS, não propriedades
      _hubConnection!.on('GateStateChanged', (arguments) {
        _handleGateStateChanged(arguments);
      });

      _hubConnection!.onclose(({error}) {
        if (kDebugMode) {
          print('SignalR connection closed: $error');
        }
      });

      _hubConnection!.onreconnecting(({error}) {
        if (kDebugMode) {
          print('SignalR reconnecting: $error');
        }
      });

      _hubConnection!.onreconnected(({connectionId}) {
        if (kDebugMode) {
          print('SignalR reconnected: $connectionId');
        }
      });

      await _hubConnection!.start();
      if (kDebugMode) {
        print('SignalR connected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to SignalR: $e');
      }
      rethrow;
    }
  }

  void _handleGateStateChanged(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      _stateController.add(data);
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
    }
  }

  void dispose() {
    disconnect();
    _stateController.close();
  }

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
}

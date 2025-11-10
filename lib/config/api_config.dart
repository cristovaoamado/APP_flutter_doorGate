class ApiConfig {
  // IMPORTANTE: Altere para o seu servidor
  static const String baseUrl = 'http://192.168.1.182:5000/api';
  static const String signalRHub = 'http://192.168.1.182:5000/hubs/gate';
  // Endpoints
  static const String register = '$baseUrl/Auth/register';
  static const String login = '$baseUrl/Auth/login';
  static const String updateFcmToken = '$baseUrl/Auth/update-fcm-token';
  static const String currentUser = '$baseUrl/Auth/me';
  
  static const String gateStatus = '$baseUrl/Gate/status';
  static const String gateControl = '$baseUrl/Gate/control';
  static const String gateHistory = '$baseUrl/Gate/history';
  
  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}

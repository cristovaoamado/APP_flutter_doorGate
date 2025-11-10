// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'auth_service.dart';

// class NotificationService {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//   static final AuthService _authService = AuthService();

//   static Future<void> initialize() async {
//     // Request permission
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       if (kDebugMode) {
//         print('User granted permission');
//       }

//       // Get FCM token
//       String? token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         if (kDebugMode) {
//           print('FCM Token: $token');
//         }
//         await _authService.updateFcmToken(token);
//       }

//       // Listen for token refresh
//       _firebaseMessaging.onTokenRefresh.listen((newToken) {
//         _authService.updateFcmToken(newToken);
//       });
//     }

//     // Initialize local notifications
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//     );

//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );

//     // Create notification channels for Android
//     const AndroidNotificationChannel gateChannel = AndroidNotificationChannel(
//       'gate_notifications',
//       'Notificações do Portão',
//       description: 'Notificações sobre o estado do portão',
//       importance: Importance.high,
//     );

//     const AndroidNotificationChannel securityChannel = AndroidNotificationChannel(
//       'security_alerts',
//       'Alertas de Segurança',
//       description: 'Alertas importantes de segurança',
//       importance: Importance.max,
//     );

//     await _localNotifications
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(gateChannel);

//     await _localNotifications
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(securityChannel);

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   }

//   static void _handleForegroundMessage(RemoteMessage message) {
//     if (kDebugMode) {
//       print('Received foreground message: ${message.notification?.title}');
//     }

//     if (message.notification != null) {
//       _showLocalNotification(
//         title: message.notification!.title ?? 'Portão',
//         body: message.notification!.body ?? '',
//         channelId: message.data['type'] == 'gate_open_too_long'
//             ? 'security_alerts'
//             : 'gate_notifications',
//       );
//     }
//   }

//   static Future<void> _showLocalNotification({
//     required String title,
//     required String body,
//     required String channelId,
//   }) async {
//     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       channelId,
//       channelId == 'security_alerts'
//           ? 'Alertas de Segurança'
//           : 'Notificações do Portão',
//       importance: channelId == 'security_alerts'
//           ? Importance.max
//           : Importance.high,
//       priority: channelId == 'security_alerts'
//           ? Priority.max
//           : Priority.high,
//     );

//     NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//     );

//     await _localNotifications.show(
//       DateTime.now().millisecond,
//       title,
//       body,
//       details,
//     );
//   }

//   static void _onNotificationTapped(NotificationResponse response) {
//     if (kDebugMode) {
//       print('Notification tapped: ${response.payload}');
//     }
//     // Handle notification tap - navigate to specific screen if needed
//   }

//   static Future<String?> getToken() async {
//     return await _firebaseMessaging.getToken();
//   }
// }

// // Top-level function for background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   if (kDebugMode) {
//     print('Background message: ${message.notification?.title}');
//   }
// }

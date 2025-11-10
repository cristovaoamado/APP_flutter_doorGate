// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'services/http_service.dart';
// import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // try {
  //   await Firebase.initializeApp();
  //   if (kDebugMode) {
  //     print('Firebase initialized successfully');
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print('Firebase initialization error: $e');
  //   }
  // }
  
  // Load auth token
  await HttpService.loadAuthToken();
  
  // Initialize notifications
  // try {
  //   await NotificationService.initialize();
  //   if (kDebugMode) {
  //     print('Notification service initialized');
  //   }
  // } catch (e) {
  //   if (kDebugMode) {
  //     print('Notification service error: $e');
  //   }
  // }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controlo do Portão',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HttpService.isAuthenticated 
          ? const HomeScreen() 
          : const LoginScreen(),
    );
  }
}

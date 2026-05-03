import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetMaterialApp ke liye zaroori hai
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp ko GetMaterialApp se badal den taake GetX ke features chalein
    return GetMaterialApp(
      title: 'Apka Hunar',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        // Yahan se 'const' hata diya gaya hai
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthBMI',
      theme: ThemeData(
        primaryColor: const Color(0xFF2C7A7B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C7A7B),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Text',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), // Khởi đầu bằng màn hình đăng nhập
    );
  }
}

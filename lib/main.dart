import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lưu ý: Bạn cần cấu hình file google-services.json trước khi chạy dòng này
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthBMI Firebase',
      theme: ThemeData(
        primaryColor: const Color(0xFF2C7A7B),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C7A7B)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm để kiểm tra database

import 'services/auth_service.dart';
import 'services/food_injector.dart'; // Import file dịch vụ nạp thực phẩm mới
import 'screens/home/home_screen.dart';
import 'screens/auth/authenticate.dart';

void main() async {
  print("========== BƯỚC 1: BẮT ĐẦU CHẠY ==========");
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("========== BƯỚC 2: KHỞI TẠO FIREBASE ==========");
    await Firebase.initializeApp();
    print("========== BƯỚC 3: FIREBASE THÀNH CÔNG ==========");
  } catch (e) {
    print('========== LỖI FIREBASE: $e ==========');
  }

  print("========== BƯỚC 4: VẼ GIAO DIỆN RUNAPP ==========");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("========== BƯỚC 5: ĐANG TẠO MYAPP ==========");
    return StreamProvider<User?>.value(
      value: AuthService().user, // Giữ nguyên luồng dữ liệu cũ của bạn
      initialData: null,
      catchError: (context, error) {
        print('========== LỖI STREAM: $error ==========');
        return null;
      },
      child: MaterialApp(
        title: 'BMI Tracker',
        debugShowCheckedModeBanner: false,
        locale: const Locale('vi', 'VN'),
        supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const Wrapper(),
      ),
    );
  }
}

// Chuyển sang StatefulWidget để tự động gọi hàm kiểm tra khi khởi chạy
class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    // Tự động kích hoạt kiểm tra kho dữ liệu thực phẩm nội bộ
    _checkAndInjectFoods();
  }

  Future<void> _checkAndInjectFoods() async {
    try {
      print("========== KIỂM TRA KHO THỰC PHẨM TRÊN FIRESTORE ==========");
      final snapshot = await FirebaseFirestore.instance.collection('foods').limit(1).get();

      // Nếu bộ sưu tập chưa có tài liệu nào, tiến hành đổ dữ liệu mẫu tự động
      if (snapshot.docs.isEmpty) {
        print("========== KHO TRỐNG: TIẾN HÀNH NẠP 30 THỰC PHẨM MẪU ==========");
        if (mounted) {
          await FoodInjector.injectDummyFoods(context);
        }
      } else {
        print("========== KHO ĐÃ CÓ DỮ LIỆU: BỎ QUA BƯỚC NẠP MẪU ==========");
      }
    } catch (e) {
      print('========== LỖI KIỂM TRA KHO THỰC PHẨM: $e ==========');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("========== BƯỚC 6: KIỂM TRA ĐĂNG NHẬP ==========");
    final user = Provider.of<User?>(context);

    if (user == null) {
      print("========== BƯỚC 7: VÀO MÀN HÌNH ĐĂNG NHẬP ==========");
      return const Authenticate();
    } else {
      print("========== BƯỚC 7: VÀO MÀN HÌNH CHÍNH (HOME) ==========");
      return const HomeScreen();
    }
  }
}
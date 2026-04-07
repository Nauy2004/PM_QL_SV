import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ChangeNotifierProvider/models/cart_model.dart';
import 'Provider/screens/home_screen.dart';
import 'Provider/screens/constructor_screen.dart';
import 'Provider/screens/callback_screen.dart';
import 'Provider/screens/provider_screen.dart';
import 'Provider/screens/stream_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provider bọc toàn app để CartModel dùng được ở mọi nơi
      create: (_) => CartModel(),
      child: MaterialApp(
        title: 'Flutter Data Passing Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5856D6),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/constructor': (_) => const ConstructorScreen(),
          '/callback': (_) => const CallbackScreen(),
          '/provider': (_) => const ProviderScreen(),
          '/stream': (_) => const StreamScreen(),
        },
      ),
    );
  }
}
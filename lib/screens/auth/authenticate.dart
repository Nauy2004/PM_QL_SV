import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'register.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng AnimatedSwitcher để tạo hiệu ứng chuyển cảnh cao cấp
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Hiệu ứng mờ dần (Fade) kết hợp trượt nhẹ (Slide)
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0), // Trượt từ phải sang trái một chút
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      // Lưu ý: Phải thêm 'key' để Flutter nhận biết đây là 2 Widget khác nhau
      child: showSignIn
          ? SignIn(key: const ValueKey('SignIn'), toggleView: toggleView)
          : Register(key: const ValueKey('Register'), toggleView: toggleView),
    );
  }
}
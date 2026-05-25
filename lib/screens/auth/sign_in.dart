import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Đảm bảo đường dẫn này đúng với dự án của bạn

class SignIn extends StatefulWidget {
  final Function toggleView;
  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Khởi tạo dịch vụ xác thực
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Trạng thái dữ liệu
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon ứng dụng
                  Icon(
                    Icons.health_and_safety_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Lời chào
                  Text(
                    'Chào mừng trở lại!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đăng nhập với tài khoản SV: ${email.contains('20222641') ? 'Tuấn' : ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Ô nhập Email
                  TextFormField(
                    validator: (val) => val!.isEmpty ? 'Vui lòng nhập Email' : null,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        email = val;
                        error = ''; // Xóa lỗi khi người dùng nhập lại
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ô nhập Mật khẩu
                  TextFormField(
                    obscureText: true,
                    validator: (val) => val!.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        password = val;
                        error = '';
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Hiển thị thông báo lỗi nếu có
                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 20),

                  // Nút Đăng nhập
                  FilledButton(
                    onPressed: loading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => loading = true);

                        // Gọi hàm đăng nhập thực tế từ AuthService
                        dynamic result = await _auth.signInWithEmailAndPassword(email, password);

                        if (result == null) {
                          setState(() {
                            error = 'Email hoặc mật khẩu không chính xác!';
                            loading = false;
                          });
                        } else {
                          // Thành công: StreamProvider ở main.dart sẽ tự động nhận diện
                          // và đẩy bạn vào HomeScreen mà không cần gọi Navigator ở đây.
                          print('Đăng nhập thành công: ${result.uid}');
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),

                  // Chuyển sang màn hình Đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Chưa có tài khoản?'),
                      TextButton(
                        onPressed: () => widget.toggleView(),
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
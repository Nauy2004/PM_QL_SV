import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';

class BmiCalculatorTab extends StatefulWidget {
  const BmiCalculatorTab({super.key});

  @override
  State<BmiCalculatorTab> createState() => _BmiCalculatorTabState();
}

class _BmiCalculatorTabState extends State<BmiCalculatorTab> {
  // Đặt giá trị mặc định cho thanh trượt
  double _weight = 60.0;
  double _height = 170.0;

  double? _bmi;
  String _bmiStatus = '';
  Color _bmiColor = Colors.grey;

  void _calculateBmi() {
    setState(() {
      // Công thức: Cân nặng (kg) / [Chiều cao (m)]^2
      _bmi = _weight / ((_height / 100) * (_height / 100));
      _determineBmiStatus();
    });
  }

  // Phân loại BMI theo chuẩn người Châu Á
  void _determineBmiStatus() {
    if (_bmi == null) return;

    if (_bmi! < 18.5) {
      _bmiStatus = 'Thiếu cân';
      _bmiColor = Colors.blue;
    } else if (_bmi! >= 18.5 && _bmi! <= 22.9) {
      _bmiStatus = 'Bình thường';
      _bmiColor = Colors.green;
    } else if (_bmi! >= 23 && _bmi! <= 24.9) {
      _bmiStatus = 'Tiền béo phì';
      _bmiColor = Colors.orange;
    } else if (_bmi! >= 25 && _bmi! <= 29.9) {
      _bmiStatus = 'Béo phì độ I';
      _bmiColor = Colors.deepOrange;
    } else {
      _bmiStatus = 'Béo phì độ II';
      _bmiColor = Colors.red;
    }
  }

  Future<void> _saveResult(String uid) async {
    if (_bmi != null) {
      await DatabaseService(uid: uid).saveBmiRecord(_weight, _height, _bmi!);

      // Kiểm tra mounted trước khi dùng BuildContext trong hàm async (Chuẩn Flutter mới)
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã lưu chỉ số BMI thành công!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating, // Hiệu ứng nổi đẹp mắt
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- THẺ CHỌN CHIỀU CAO ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    const Text('CHIỀU CAO', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _height.round().toString(),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const Text(' cm', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    Slider(
                      value: _height,
                      min: 100.0,
                      max: 220.0,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) => setState(() => _height = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- THẺ CHỌN CÂN NẶNG ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    const Text('CÂN NẶNG', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _weight.round().toString(),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const Text(' kg', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    Slider(
                      value: _weight,
                      min: 30.0,
                      max: 150.0,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) => setState(() => _weight = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- NÚT TÍNH TOÁN ---
            FilledButton(
              onPressed: _calculateBmi,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('TÍNH TOÁN BMI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            // --- HIỂN THỊ KẾT QUẢ KHI ĐÃ TÍNH ---
            if (_bmi != null) ...[
              Card(
                color: _bmiColor.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _bmiColor, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Chỉ số của bạn',
                        style: TextStyle(fontSize: 16, color: _bmiColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _bmi!.toStringAsFixed(1),
                        style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: _bmiColor),
                      ),
                      Text(
                        _bmiStatus,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _bmiColor),
                      ),
                      const SizedBox(height: 20),

                      // Nút Lưu Kết Quả
                      OutlinedButton.icon(
                        onPressed: user != null ? () => _saveResult(user.uid) : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu vào lịch sử'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _bmiColor,
                          side: BorderSide(color: _bmiColor),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
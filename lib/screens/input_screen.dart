import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/health_record.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double _bmi = 0;
  String _category = '';
  Color _categoryColor = Colors.grey;

  void _calculateBMI() {
    final double height = double.tryParse(_heightController.text) ?? 0;
    final double weight = double.tryParse(_weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      final double bmi = weight / ((height / 100) * (height / 100));
      setState(() {
        _bmi = bmi;
        _updateCategory(bmi);
      });
    }
  }

  void _updateCategory(double bmi) {
    if (bmi < 18.5) {
      _category = 'Thiếu cân';
      _categoryColor = Colors.orange;
    } else if (bmi < 25) {
      _category = 'Bình thường';
      _categoryColor = Colors.green;
    } else if (bmi < 30) {
      _category = 'Thừa cân';
      _categoryColor = Colors.red;
    } else {
      _category = 'Béo phì';
      _categoryColor = Colors.purple;
    }
  }

  Future<void> _saveRecord() async {
    if (_bmi > 0) {
      final record = HealthRecord(
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        bmi: _bmi,
        category: _category,
        createdAt: DateTime.now(),
      );

      await DatabaseHelper.instance.insertRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu chỉ số vào cơ sở dữ liệu!'),
            backgroundColor: Color(0xFF2C7A7B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật chỉ số'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Date picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ngày:'),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateTime.now().toString().split(' ')[0],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Height input
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Chiều cao (cm)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 16),
            // Weight input
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cân nặng (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.monitor_weight),
              ),
            ),
            const SizedBox(height: 24),
            // Calculate button
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C7A7B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Tính BMI',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            // Result card
            if (_bmi > 0)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Kết quả BMI',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            // Save button
            if (_bmi > 0)
              ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2C7A7B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xFF2C7A7B)),
                  ),
                ),
                child: const Text(
                  '💾 Lưu chỉ số',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

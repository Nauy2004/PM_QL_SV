import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/health_record.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  double _bmi = 0;
  String _category = '';
  Color _categoryColor = Colors.grey;
  bool _isSaving = false;

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
      setState(() => _isSaving = true);
      try {
        final record = HealthRecord(
          weight: double.parse(_weightController.text),
          height: double.parse(_heightController.text),
          bmi: _bmi,
          category: _category,
          createdAt: DateTime.now(),
        );

        await _firebaseService.addRecord(record);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã lưu lên Cloud thành công!'),
              backgroundColor: Color(0xFF2C7A7B),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật chỉ số Cloud'),
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
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Chiều cao (cm)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cân nặng (kg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.monitor_weight),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C7A7B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Tính BMI', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            if (_bmi > 0) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('Kết quả BMI', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _category,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _isSaving 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _saveRecord,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Lưu lên Firebase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
            ]
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/health_record.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _selectedPeriod = 'Ngày';
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biểu đồ Cloud'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<HealthRecord>>(
        stream: _firebaseService.getRecordsStream(),
        builder: (context, snapshot) {
          final allRecords = snapshot.data ?? [];
          final filteredRecords = _filterRecords(allRecords);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildSegment('Ngày'),
                      _buildSegment('Tuần'),
                      _buildSegment('Tháng'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Chart Display
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 250,
                        child: filteredRecords.isEmpty
                            ? const Center(child: Text('Chưa có dữ liệu trên mây'))
                            : CustomPaint(
                                size: Size.infinite,
                                painter: BMILinePainter(records: filteredRecords),
                              ),
                      ),
                      const SizedBox(height: 20),
                      _buildLegend(filteredRecords),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildAnalysis(filteredRecords),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HealthRecord> _filterRecords(List<HealthRecord> all) {
    if (all.isEmpty) return [];
    DateTime now = DateTime.now();
    
    if (_selectedPeriod == 'Ngày') {
      return all.length > 5 ? all.sublist(all.length - 5) : all;
    } else if (_selectedPeriod == 'Tuần') {
      DateTime weekAgo = now.subtract(const Duration(days: 7));
      return all.where((r) => r.createdAt.isAfter(weekAgo)).toList();
    } else {
      DateTime monthAgo = now.subtract(const Duration(days: 30));
      return all.where((r) => r.createdAt.isAfter(monthAgo)).toList();
    }
  }

  Widget _buildSegment(String text) {
    bool isSelected = _selectedPeriod == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2C7A7B) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(List<HealthRecord> records) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: records.map((r) {
        return Text(
          '${r.createdAt.day}/${r.createdAt.month}',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        );
      }).toList(),
    );
  }

  Widget _buildAnalysis(List<HealthRecord> records) {
    if (records.isEmpty) return const SizedBox();
    double avg = records.map((r) => r.bmi).reduce((a, b) => a + b) / records.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C7A7B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF2C7A7B)),
              SizedBox(width: 8),
              Text('Phân tích mây', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text('• BMI trung bình trong $_selectedPeriod: ${avg.toStringAsFixed(1)}'),
          Text('• Số lần ghi nhận: ${records.length}'),
        ],
      ),
    );
  }
}

class BMILinePainter extends CustomPainter {
  final List<HealthRecord> records;
  BMILinePainter({required this.records});

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;
    
    final paint = Paint()
      ..color = const Color(0xFF2C7A7B)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (records.length == 1) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6, Paint()..color = const Color(0xFF2C7A7B));
      return;
    }

    final double spacing = size.width / (records.length - 1);
    final List<Offset> points = [];

    double minBmi = records.map((r) => r.bmi).reduce((a, b) => a < b ? a : b) - 1;
    double maxBmi = records.map((r) => r.bmi).reduce((a, b) => a > b ? a : b) + 1;
    double range = maxBmi - minBmi;

    for (int i = 0; i < records.length; i++) {
      double x = i * spacing;
      double y = size.height - ((records[i].bmi - minBmi) / (range == 0 ? 1 : range) * size.height);
      points.add(Offset(x, y));
    }

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    final pointPaint = Paint()..color = const Color(0xFF2C7A7B);
    for (var point in points) {
      canvas.drawCircle(point, 5, pointPaint);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

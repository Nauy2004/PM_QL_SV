import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/health_record.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: DatabaseHelper.instance.onDbUpdate,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gợi ý tập luyện'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: FutureBuilder<List<HealthRecord>>(
            future: DatabaseHelper.instance.getAllRecords(),
            builder: (context, snapshot) {
              final records = snapshot.data ?? [];
              final category = records.isNotEmpty ? records.last.category : 'Bình thường';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(category),
                    const SizedBox(height: 24),
                    const Text(
                      'Bài tập phù hợp với bạn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ..._getExercisesForCategory(category).map((ex) => _buildExerciseCard(ex)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(String category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C7A7B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chế độ tập luyện',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'Dành cho người $category',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getExercisesForCategory(String category) {
    if (category.contains('Gầy')) {
      return [
        {'title': 'Nâng tạ nhẹ', 'time': '20 phút', 'level': 'Dễ', 'desc': 'Giúp kích thích cơ bắp phát triển.'},
        {'title': 'Chống đẩy', 'time': '15 phút', 'level': 'Vừa', 'desc': 'Tăng cường sức mạnh thân trên.'},
        {'title': 'Yoga tăng cân', 'time': '30 phút', 'level': 'Dễ', 'desc': 'Cân bằng trao đổi chất.'},
      ];
    } else if (category.contains('Thừa cân') || category.contains('Béo phì')) {
      return [
        {'title': 'Chạy bộ nhẹ', 'time': '40 phút', 'level': 'Vừa', 'desc': 'Đốt cháy calo hiệu quả.'},
        {'title': 'Nhảy dây', 'time': '15 phút', 'level': 'Khó', 'desc': 'Tiêu hao mỡ thừa cực nhanh.'},
        {'title': 'Đạp xe', 'time': '30 phút', 'level': 'Vừa', 'desc': 'Tăng sức bền hệ tim mạch.'},
      ];
    } else {
      return [
        {'title': 'Chạy bộ', 'time': '30 phút', 'level': 'Vừa', 'desc': 'Duy trì vóc dáng cân đối.'},
        {'title': 'Plank', 'time': '5 phút', 'level': 'Vừa', 'desc': 'Giúp cơ bụng săn chắc.'},
        {'title': 'Bơi lội', 'time': '45 phút', 'level': 'Khó', 'desc': 'Phát triển toàn diện cơ thể.'},
      ];
    }
  }

  Widget _buildExerciseCard(Map<String, String> ex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.play_circle_fill, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${ex['time']} • Mức độ: ${ex['level']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(ex['desc']!, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

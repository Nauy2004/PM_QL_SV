import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/health_record.dart';
import '../widgets/bmi_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'input_screen.dart';
import 'chart_screen.dart';
import 'meal_screen.dart';
import 'exercise_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardContent(),
    const InputScreen(),
    const ChartScreen(),
    const MealScreen(),
    const ExerciseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: DatabaseHelper.instance.onDbUpdate,
      builder: (context, snapshot) {
        return FutureBuilder<List<HealthRecord>>(
          future: DatabaseHelper.instance.getAllRecords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final records = snapshot.data ?? [];
            final hasData = records.isNotEmpty;
            final latestRecord = hasData ? records.last : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Xin chào! 👋',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  if (hasData)
                    BmiCard(
                      bmi: latestRecord!.bmi,
                      category: latestRecord.category,
                      color: _getCategoryColor(latestRecord.category),
                    )
                  else
                    _buildNoDataCard(),

                  const SizedBox(height: 24),
                  const Text('Xu hướng BMI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildSimpleChart(records),
                  
                  const SizedBox(height: 24),
                  const Text('Gợi ý nhanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSuggestionCard(
                          icon: Icons.restaurant,
                          title: 'Thực đơn',
                          subtitle: 'Xem gợi ý',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSuggestionCard(
                          icon: Icons.fitness_center,
                          title: 'Luyện tập',
                          subtitle: hasData ? 'Dành cho ${latestRecord!.category}' : 'Bắt đầu ngay',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    if (category.contains('Gầy')) return Colors.orange;
    if (category.contains('Bình thường')) return Colors.green;
    if (category.contains('Thừa cân')) return Colors.red;
    return Colors.purple;
  }

  Widget _buildNoDataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        children: [
          Icon(Icons.analytics_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Chưa có dữ liệu BMI', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Hãy sang tab "Nhập số" để bắt đầu', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(List<HealthRecord> records) {
    final recentRecords = records.length > 7 ? records.sublist(records.length - 7) : records;
    
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: recentRecords.isEmpty 
        ? const Center(child: Text('Cần thêm dữ liệu để vẽ biểu đồ', style: TextStyle(color: Colors.grey, fontSize: 12)))
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: recentRecords.map((r) => _buildBar(r)).toList(),
          ),
    );
  }

  Widget _buildBar(HealthRecord record) {
    double h = (record.bmi - 15).clamp(5, 40) * 2.5;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xFF2C7A7B),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${record.createdAt.day}/${record.createdAt.month}',
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

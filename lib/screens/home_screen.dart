import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/health_record.dart';
import '../widgets/bmi_card.dart';
import '../widgets/bottom_nav_bar.dart';
import 'input_screen.dart';
import 'chart_screen.dart';
import 'meal_screen.dart';
import 'exercise_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();

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
      appBar: AppBar(
        title: const Text('Health Tracker Cloud'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _firebaseService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<List<HealthRecord>>(
      stream: firebaseService.getRecordsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data ?? [];
        final hasData = records.isNotEmpty;
        final latest = hasData ? records.last : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasData)
                BmiCard(
                  bmi: latest!.bmi,
                  category: latest.category,
                  color: latest.bmi < 18.5 ? Colors.orange : (latest.bmi < 25 ? Colors.green : Colors.red),
                )
              else
                const Center(child: Text('Chưa có dữ liệu trên mây')),
              
              const SizedBox(height: 30),
              const Text('Lịch sử gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ...records.reversed.take(3).map((r) => ListTile(
                leading: const Icon(Icons.history),
                title: Text('${r.weight} kg - ${r.category}'),
                subtitle: Text(r.createdAt.toString().split('.')[0]),
              )),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'dashboard_tab.dart';
import 'bmi_calculator_tab.dart';
import 'meals_tab.dart';
import 'workouts_tab.dart';
import 'profile_tab.dart';
import 'history_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  int _selectedIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình con
    final List<Widget> widgetOptions = [
      DashboardTab(onActionPressed: () => _changeTab(1)),
      const BmiCalculatorTab(),
      const MealsTab(),
      const WorkoutsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Theo dõi sức khỏe', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true, // Căn giữa tiêu đề theo chuẩn iOS/Material 3 hiện đại
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0, // Tắt hiệu ứng đổ bóng mặc định khi cuộn của M3
        actions: [
          // Nút xem Lịch sử
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Lịch sử BMI',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  appBar: AppBar(
                    title: const Text('Lịch sử đo BMI', style: TextStyle(fontWeight: FontWeight.bold)),
                    centerTitle: true,
                  ),
                  body: const HistoryTab(),
                )),
              );
            },
          ),
          // Nút Đăng xuất
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            color: Theme.of(context).colorScheme.error, // Tô màu đỏ để cảnh báo nhẹ
            onPressed: () async => await _auth.signOut(),
          )
        ],
      ),

      // Hiển thị màn hình tương ứng với Tab đang chọn
      body: widgetOptions.elementAt(_selectedIndex),

      // Sử dụng NavigationBar chuẩn Material 3 thay cho BottomNavigationBar cũ
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // Khai báo các Tab với 2 trạng thái: Chưa chọn (Outlined) và Đã chọn (Filled)
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Đo BMI',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Thực đơn',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Tập luyện',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
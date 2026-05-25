import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../domain/models/bmi_record.dart';
import 'stats_detail_screen.dart'; // Đảm bảo bạn đã có màn hình này

class DashboardTab extends StatelessWidget {
  final VoidCallback onActionPressed;

  const DashboardTab({super.key, required this.onActionPressed});

  // --- THUẬT TOÁN TÍNH CALO MỤC TIÊU DỰA TRÊN BMI CHUẨN CHÂU Á ---
  int _calculateTargetCalories(double bmi) {
    if (bmi < 18.5) return 2500; // Cần tăng cân
    if (bmi <= 22.9) return 2000; // Duy trì lý tưởng
    return 1500; // Cần giảm cân
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final db = DatabaseService(uid: user.uid);

    // Bọc toàn bộ Dashboard bằng Stream lấy dữ liệu BMI mới nhất
    return StreamBuilder<List<BmiRecord>>(
      stream: db.bmiHistory,
      builder: (context, bmiSnapshot) {

        // Mặc định BMI là 22.0 (Bình thường) nếu người dùng chưa từng đo
        double currentBmi = 22.0;
        if (bmiSnapshot.hasData && bmiSnapshot.data!.isNotEmpty) {
          currentBmi = bmiSnapshot.data!.first.bmi;
        }

        // Tính ra lượng Calo tối đa nên nạp trong ngày
        int targetCalories = _calculateTargetCalories(currentBmi);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Chào mừng ${user.displayName ?? 'bạn'} trở lại!',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)
              ),
              Text(
                  'Tổng quan Sức khỏe',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
              ),
              const SizedBox(height: 24),

              // --- KHỐI THẺ CALO ---
              Row(
                children: [
                  // 1. Thẻ Calo Nạp Vào (Hiển thị Mục tiêu + Thanh tiến trình)
                  StreamBuilder<int>(
                      stream: db.todayCaloriesIn,
                      builder: (context, snapshot) {
                        final int calInValue = snapshot.data ?? 0;
                        return _buildCalorieCard(
                            context,
                            title: 'Nạp vào',
                            currentValue: calInValue,
                            targetValue: targetCalories, // Truyền mục tiêu lấy từ BMI vào đây
                            icon: Icons.restaurant_rounded,
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => StatsDetailScreen(
                                  title: 'Calo nạp vào',
                                  themeColor: Colors.green,
                                  isBmi: false,
                                  todayValue: calInValue.toDouble(),
                                ),
                              ));
                            }
                        );
                      }
                  ),
                  const SizedBox(width: 16),

                  // 2. Thẻ Calo Tiêu Hao (Không cần mục tiêu)
                  StreamBuilder<int>(
                      stream: db.todayCaloriesBurned,
                      builder: (context, snapshot) {
                        final int calBurnValue = snapshot.data ?? 0;
                        return _buildCalorieCard(
                            context,
                            title: 'Tiêu hao',
                            currentValue: calBurnValue,
                            targetValue: null, // Tiêu hao càng nhiều càng tốt nên không set giới hạn
                            icon: Icons.local_fire_department_rounded,
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => StatsDetailScreen(
                                  title: 'Calo tiêu hao',
                                  themeColor: Colors.orange,
                                  isBmi: false,
                                  todayValue: calBurnValue.toDouble(),
                                ),
                              ));
                            }
                        );
                      }
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- KHỐI HIỂN THỊ CHỈ SỐ BMI ---
              if (bmiSnapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (!bmiSnapshot.hasData || bmiSnapshot.data!.isEmpty)
                _buildActionCard(
                    context,
                    'Tính BMI lần đầu tiên',
                    Icons.calculate_rounded,
                    Theme.of(context).colorScheme.primary,
                    onActionPressed
                )
              else
                _buildBmiDisplay(context, bmiSnapshot.data!.first),

              const SizedBox(height: 32),
              Text(
                  'Tác vụ nhanh',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
              ),
              const SizedBox(height: 16),

              _buildInsightCard(
                  context,
                  'Cập nhật BMI',
                  'Nhập chỉ số cân nặng/chiều cao mới',
                  Icons.add_chart_rounded,
                  Theme.of(context).colorScheme.primary,
                  onActionPressed
              ),
            ],
          ),
        );
      },
    );
  }

  // --- DESIGN: KHỐI THẺ ĐỒNG HỒ CALO CÓ THANH TIẾN TRÌNH ---
  Widget _buildCalorieCard(
      BuildContext context, {
        required String title,
        required int currentValue,
        int? targetValue, // Nếu có Target sẽ hiện Progress Bar
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {

    // Tính toán phần trăm hoàn thành
    double progress = 0;
    if (targetValue != null && targetValue > 0) {
      progress = currentValue / targetValue;
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8)
            )
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),

                // --- KHOẢNG ĐỔI MỚI: HIỂN THỊ SỐ LIỆU LINH HOẠT ---
                if (targetValue != null)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: '$currentValue',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
                        ),
                        TextSpan(
                            text: ' / $targetValue',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)
                        ),
                      ],
                    ),
                  )
                else
                  Text('$currentValue kcal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                const SizedBox(height: 4),
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),

                // --- THANH TIẾN TRÌNH TRỰC QUAN ---
                if (targetValue != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress > 1.0 ? 1.0 : progress, // Giới hạn max là 1.0
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 1.0 ? Colors.redAccent : color, // Cảnh báo ĐỎ nếu ăn lố calo!
                      ),
                      minHeight: 6,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DESIGN: KHỐI THẺ ĐỒNG HỒ BMI ---
  Widget _buildBmiDisplay(BuildContext context, BmiRecord record) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [primaryColor, tertiaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: primaryColor.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10)
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => StatsDetailScreen(
              title: 'Biến động BMI',
              themeColor: primaryColor,
              isBmi: true,
              todayValue: record.bmi,
            ),
          ));
        },
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chỉ số BMI hiện tại', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                      record.bmi.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        record.status,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)
                    ),
                  ),
                ],
              ),
              const Icon(Icons.speed_rounded, color: Colors.white24, size: 90),
            ],
          ),
        ),
      ),
    );
  }

  // --- DESIGN: NÚT NHẮC ĐO BMI ---
  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.2), width: 2)
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  // --- DESIGN: THẺ TÁC VỤ NHANH KIỂU DANH SÁCH ---
  Widget _buildInsightCard(BuildContext context, String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(desc, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chevron_right_rounded, size: 20),
        ),
      ),
    );
  }
}
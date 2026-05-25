import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/workout.dart';
import '../../services/notification_service.dart';
import '../../services/database_service.dart';

class WorkoutsTab extends StatefulWidget {
  const WorkoutsTab({super.key});

  @override
  State<WorkoutsTab> createState() => _WorkoutsTabState();
}

class _WorkoutsTabState extends State<WorkoutsTab> {
  final List<Workout> _workouts = List.from(defaultWorkouts);
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // Xử lý an toàn nếu chưa đăng nhập
    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập để xem bài tập'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- THẺ ĐẶT LỊCH NHẮC NHỞ ---
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fitness_center_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Mục tiêu Thể lực',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Duy trì thói quen vận động mỗi ngày để cải thiện chỉ số BMI của bạn.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Nút Bật nhắc nhở
              FilledButton.icon(
                onPressed: () async {
                  await _notificationService.scheduleWorkoutReminder();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.alarm_on_rounded, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Đã đặt lịch! Sẽ có thông báo nhắc nhở bạn.'),
                          ],
                        ),
                        backgroundColor: Colors.orange.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.alarm_add_rounded, color: Colors.orange),
                label: const Text('Bật nhắc nhở', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              )
            ],
          ),
        ),

        // --- TIÊU ĐỀ DANH SÁCH ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'Các bài tập đề xuất',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),

        // --- DANH SÁCH BÀI TẬP ---
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: _workouts.length,
            itemBuilder: (context, index) {
              final workout = _workouts[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: workout.isCompleted
                            ? Colors.green.withOpacity(0.15)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        // Sử dụng icon chạy bộ phù hợp với thói quen
                        Icons.directions_run_rounded,
                        color: workout.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      workout.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: workout.isCompleted ? TextDecoration.lineThrough : null,
                        color: workout.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text(
                      '${workout.duration} • ${workout.caloriesPerMinute} kcal/phút',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),

                    // Nút Hoàn thành (Thay đổi trạng thái khi bấm)
                    trailing: workout.isCompleted
                        ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 32)
                        : FilledButton.tonal(
                      onPressed: () async {
                        // Giả lập thời gian tập 30 phút (Có thể mở rộng cho người dùng tự nhập số phút sau này)
                        int burned = workout.caloriesPerMinute * 30;
                        await DatabaseService(uid: user.uid).logWorkout(workout.name, burned);

                        setState(() {
                          workout.isCompleted = true;
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tuyệt vời! Đã tiêu hao $burned kcal từ bài ${workout.name}'),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hoàn thành'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
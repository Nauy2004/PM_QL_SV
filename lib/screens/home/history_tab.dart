import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../domain/models/bmi_record.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập để xem lịch sử'));
    }

    return StreamBuilder<List<BmiRecord>>(
      stream: DatabaseService(uid: user.uid).bmiHistory,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Đã xảy ra lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<BmiRecord>? history = snapshot.data;

        if (history == null || history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có dữ liệu lịch sử.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy đo và lưu chỉ số BMI đầu tiên của bạn!',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: history.length,
          itemBuilder: (context, index) {
            BmiRecord record = history[history.length - 1 - index];

            Color statusColor = _getStatusColor(record.bmi);
            String statusText = _getStatusText(record.bmi);

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Cột bên trái: Khối hiển thị điểm số BMI
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        // ĐÃ SỬA LỖI Ở ĐÂY: Thêm Border.all
                        border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          record.bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Cột ở giữa: Thông tin cân nặng, chiều cao và ngày giờ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${record.weight.round()} kg',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text(' • ', style: TextStyle(color: Colors.grey)),
                              Text(
                                '${record.height.round()} cm',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('dd/MM/yyyy  HH:mm').format(record.timestamp),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cột bên phải: Nhãn Trạng thái
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Đồng bộ logic tính chuẩn BMI Châu Á với các màn hình khác
  Color _getStatusColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi <= 22.9) return Colors.green;
    if (bmi <= 24.9) return Colors.orange;
    if (bmi <= 29.9) return Colors.deepOrange;
    return Colors.red;
  }

  String _getStatusText(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi <= 22.9) return 'Bình thường';
    if (bmi <= 24.9) return 'Tiền béo phì';
    if (bmi <= 29.9) return 'Béo phì độ I';
    return 'Béo phì độ II';
  }
}
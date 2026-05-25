import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../domain/models/user_profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();

  // Dữ liệu tạm thời khi người dùng chỉnh sửa
  String? _currentName;
  int? _currentAge;
  double? _currentGoalWeight;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập để xem hồ sơ'));
    }

    return StreamBuilder<UserProfile>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          UserProfile? userData = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // --- PHẦN AVATAR & TÊN ---
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).colorScheme.surface, width: 3),
                        ),
                        child: const Icon(Icons.edit_rounded, size: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _currentName ?? userData?.name ?? 'Người dùng',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email ?? '',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 40),

                // --- PHẦN FORM NHẬP LIỆU ---
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                          'Thông tin cá nhân',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 16),

                      // Ô nhập Tên hiển thị
                      _buildTextField(
                        context: context,
                        initialValue: userData?.name,
                        label: 'Tên hiển thị',
                        icon: Icons.badge_outlined,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên của bạn' : null,
                        onChanged: (val) => setState(() => _currentName = val),
                      ),
                      const SizedBox(height: 16),

                      // Ô nhập Tuổi
                      _buildTextField(
                        context: context,
                        initialValue: userData?.age?.toString(),
                        label: 'Tuổi',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tuổi' : null,
                        onChanged: (val) {
                          // Sử dụng tryParse để tránh văng app khi người dùng xóa trắng ô nhập liệu
                          setState(() => _currentAge = int.tryParse(val) ?? userData?.age);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Ô nhập Mục tiêu cân nặng
                      _buildTextField(
                        context: context,
                        initialValue: userData?.goalWeight?.toString(),
                        label: 'Mục tiêu cân nặng (kg)',
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập mục tiêu' : null,
                        onChanged: (val) {
                          setState(() => _currentGoalWeight = double.tryParse(val) ?? userData?.goalWeight);
                        },
                      ),
                      const SizedBox(height: 32),

                      // --- NÚT LƯU THÔNG TIN ---
                      FilledButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        label: const Text(
                          'CẬP NHẬT HỒ SƠ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Cất bàn phím đi khi bấm lưu
                            FocusScope.of(context).unfocus();

                            await DatabaseService(uid: user.uid).updateUserData(
                              _currentName ?? userData!.name,
                              _currentAge ?? userData!.age,
                              _currentGoalWeight ?? userData!.goalWeight,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text('Cập nhật hồ sơ thành công!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('Không tìm thấy dữ liệu người dùng.'));
        }
      },
    );
  }

  // --- HÀM TẠO Ô NHẬP LIỆU CHUẨN MATERIAL 3 ---
  Widget _buildTextField({
    required BuildContext context,
    required String? initialValue,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
        ),
      ),
    );
  }
}
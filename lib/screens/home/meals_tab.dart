import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../domain/models/bmi_record.dart';

class MealsTab extends StatefulWidget {
  const MealsTab({super.key});

  @override
  State<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends State<MealsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  final List<String> _categories = ['Tất cả', 'Thịt', 'Cá', 'Rau', 'Hoa quả', 'Hải sản', 'Tinh bột'];
  String _selectedCategory = 'Tất cả';

  String _getBmiTarget(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi <= 22.9) return 'Normal';
    if (bmi <= 24.9) return 'Overweight';
    return 'Obese';
  }

  String _getBmiStatusText(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân (Ưu tiên thực phẩm giàu dinh dưỡng)';
    if (bmi <= 22.9) return 'Bình thường (Duy trì chế độ ăn ổn định)';
    if (bmi <= 24.9) return 'Tiền béo phì (Ưu tiên đạm sạch & rau xanh)';
    return 'Béo phì (Kiểm soát calo nghiêm ngặt)';
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // --- HÀM LƯU MÓN ĂN ĐỒNG BỘ 100% VỚI DATABASESERVICE CỦA BẠN ---
  Future<void> _addFoodToMeal(String userId, String foodName, int calories, String mealType) async {
    final String dateStr = _getTodayDateString();

    try {
      // Ghi trực tiếp vào collection 'meals' với cấu trúc trường khớp với file DatabaseService
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('meals')
          .add({
        'name': foodName,
        'calories': calories.toString(), // DatabaseService của bạn parse từ String
        'category': mealType,
        'timestamp': FieldValue.serverTimestamp(),
        'date': dateStr, // Giữ lại trường này để tab Thực đơn dễ dàng lọc dữ liệu hôm nay
      });

      // KHÔNG CẦN TRANSACTION NỮA: Luồng Stream todayCaloriesIn sẽ tự động quét collection 'meals' và tính tổng ngay lập tức!

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Đã thêm "$foodName" vào $mealType. +$calories kcal!'),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Lỗi khi lưu thực đơn: $e");
    }
  }

  void _showMealTypeSelectionDialog(String userId, String foodName, int calories) {
    final List<String> mealTypes = ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Bữa phụ'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Thêm vào thực đơn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Text('Bạn muốn thêm món "$foodName" ($calories kcal) vào bữa ăn nào hôm nay?'),
          actions: List.generate(mealTypes.length, (index) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _addFoodToMeal(userId, foodName, calories, mealTypes[index]);
                },
                child: Text(mealTypes[index], style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildTodayMenuSection(user.uid),
            ),
          ];
        },
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Kho thực phẩm đề xuất',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Tìm thực phẩm (Ức gà, Táo)...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                    _isSearching = _searchQuery.isNotEmpty;
                  });
                },
                leading: const Icon(Icons.search, color: Colors.teal),
                trailing: [
                  if (_isSearching)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                    ),
                ],
                elevation: WidgetStateProperty.all(1),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedCategory == _categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(_categories[index]),
                        selected: isSelected,
                        selectedColor: Colors.teal,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isSelected ? Colors.teal : Colors.grey.shade300),
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = _categories[index];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: _isSearching
                  ? _buildSearchResults(user.uid)
                  : _buildSuggestedList(user),
            ),
          ],
        ),
      ),
    );
  }

  // --- LẮNG NGHE ĐÚNG COLLECTION 'meals' ĐỂ HIỂN THỊ THỰC ĐƠN ---
  Widget _buildTodayMenuSection(String userId) {
    final String todayStr = _getTodayDateString();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('meals') // Sửa thành 'meals'
          .where('date', isEqualTo: todayStr)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        Map<String, List<Map<String, dynamic>>> mealMap = {
          'Bữa sáng': [],
          'Bữa trưa': [],
          'Bữa tối': [],
          'Bữa phụ': [],
        };

        int totalDayCalories = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          String type = data['category'] ?? 'Bữa phụ';

          // Parse lượng calo từ cấu trúc String giống hệt DatabaseService
          String calStr = data['calories'].toString().replaceAll(RegExp(r'[^0-9]'), '');
          int cal = int.tryParse(calStr) ?? 0;

          totalDayCalories += cal;

          if (mealMap.containsKey(type)) {
            mealMap[type]!.add({
              'name': data['name'] ?? '',
              'calories': cal,
              'id': doc.id
            });
          }
        }

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment_turned_in_rounded, color: Colors.teal),
                        SizedBox(width: 8),
                        Text('Thực đơn hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('$totalDayCalories kcal nạp', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15)),
                  ],
                ),
                const Divider(height: 24, thickness: 1),

                ...mealMap.entries.map((entry) {
                  return _buildMealGroupRow(entry.key, entry.value, userId);
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealGroupRow(String mealTitle, List<Map<String, dynamic>> items, String userId) {
    int groupTotal = items.fold(0, (sum, item) => sum + (item['calories'] as int));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mealTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
              if (groupTotal > 0)
                Text('$groupTotal kcal', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          if (items.isEmpty)
            Text('Chưa thêm món ăn nào', style: TextStyle(color: Colors.grey[400], fontSize: 13, fontStyle: FontStyle.italic))
          else
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${item['name']} (${item['calories']} kcal)', style: const TextStyle(fontSize: 13, color: Colors.teal, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () async {
                          // Chỉ cần xóa document khỏi Firebase, Stream ngoài Dashboard sẽ tự động tính lại tổng và tự trừ đi!
                          await FirebaseFirestore.instance.collection('users').doc(userId).collection('meals').doc(item['id']).delete();
                        },
                        child: const Icon(Icons.cancel, size: 14, color: Colors.teal),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('foods').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final filteredFoods = docs.where((doc) {
          String name = (doc['name'] ?? '').toString().toLowerCase();
          String type = doc['type'] ?? '';
          return name.contains(_searchQuery) && (_selectedCategory == 'Tất cả' || type == _selectedCategory);
        }).toList();

        return _buildList(filteredFoods, userId);
      },
    );
  }

  Widget _buildSuggestedList(User user) {
    return StreamBuilder<List<BmiRecord>>(
      stream: DatabaseService(uid: user.uid).bmiHistory,
      builder: (context, bmiSnapshot) {
        double currentBmi = (bmiSnapshot.hasData && bmiSnapshot.data!.isNotEmpty) ? bmiSnapshot.data!.first.bmi : 22.0;
        String statusText = _getBmiStatusText(currentBmi);
        String targetGroup = _getBmiTarget(currentBmi);

        Query query = FirebaseFirestore.instance.collection('foods');
        if (_selectedCategory != 'Tất cả') {
          query = query.where('type', isEqualTo: _selectedCategory);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, foodSnapshot) {
            if (foodSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final foodDocs = foodSnapshot.data?.docs ?? [];
            List<QueryDocumentSnapshot> sortedDocs = List.from(foodDocs);

            sortedDocs.sort((a, b) {
              String targetA = a['bmiTarget'] ?? '';
              String targetB = b['bmiTarget'] ?? '';
              if (targetA == targetGroup && targetB != targetGroup) return -1;
              if (targetA != targetGroup && targetB == targetGroup) return 1;
              return 0;
            });

            return _buildList(sortedDocs, user.uid, title: _selectedCategory == 'Tất cả' ? "Khuyến nghị: $statusText" : null);
          },
        );
      },
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot> items, String userId, {String? title}) {
    if (items.isEmpty) {
      return Center(child: Text("Không thấy thực phẩm nào thuộc nhóm này", style: TextStyle(color: Colors.grey[400])));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length + (title != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (title != null && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4, top: 8),
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
          );
        }

        final item = items[title != null ? index - 1 : index];
        String foodName = item['name'] ?? 'Thực phẩm';
        int calories = item['calories'] ?? 0;
        String foodCategory = item['category'] ?? 'Bữa ăn';
        String foodType = item['type'] ?? 'Chưa phân loại';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  height: 60, width: 60,
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.restaurant_rounded, color: Colors.teal, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(foodName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(foodType, style: const TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text(foodCategory, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('$calories kcal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Colors.teal, size: 28),
                  onPressed: () => _showMealTypeSelectionDialog(userId, foodName, calories),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
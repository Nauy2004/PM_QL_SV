import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/health_record.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final Map<String, List<Map<String, dynamic>>> _foodCategories = {
    'Rau củ (100g)': [
      {'name': 'Bông cải xanh', 'icon': '🥦', 'cal': 34},
      {'name': 'Cà rốt', 'icon': '🥕', 'cal': 41},
      {'name': 'Rau muống', 'icon': '🥗', 'cal': 19},
      {'name': 'Bắp cabbage', 'icon': '🥬', 'cal': 25},
      {'name': 'Bí đỏ', 'icon': '🎃', 'cal': 26},
      {'name': 'Cà chua', 'icon': '🍅', 'cal': 18},
      {'name': 'Dưa leo', 'icon': '🥒', 'cal': 15},
      {'name': 'Măng tây', 'icon': '🎋', 'cal': 20},
    ],
    'Trái cây (100g)': [
      {'name': 'Táo', 'icon': '🍎', 'cal': 52},
      {'name': 'Chuối', 'icon': '🍌', 'cal': 88},
      {'name': 'Bơ', 'icon': '🥑', 'cal': 160},
      {'name': 'Cam', 'icon': '🍊', 'cal': 47},
      {'name': 'Xoài', 'icon': '🥭', 'cal': 60},
      {'name': 'Dưa hấu', 'icon': '🍉', 'cal': 30},
      {'name': 'Dứa', 'icon': '🍍', 'cal': 50},
      {'name': 'Đu đủ', 'icon': '🍈', 'cal': 42},
    ],
    'Thịt & Đạm (100g)': [
      {'name': 'Ức gà', 'icon': '🍗', 'cal': 165},
      {'name': 'Thịt bò', 'icon': '🥩', 'cal': 250},
      {'name': 'Cá hồi', 'icon': '🐟', 'cal': 208},
      {'name': 'Trứng (2 quả)', 'icon': '🥚', 'cal': 155},
      {'name': 'Thịt lợn nạc', 'icon': '🐖', 'cal': 145},
      {'name': 'Đậu phụ', 'icon': '🧊', 'cal': 76},
      {'name': 'Tôm', 'icon': '🦐', 'cal': 99},
      {'name': 'Cá rô phi', 'icon': '🐠', 'cal': 128},
    ],
    'Tinh bột (100g)': [
      {'name': 'Cơm trắng', 'icon': '🍚', 'cal': 130},
      {'name': 'Gạo lứt', 'icon': '🌾', 'cal': 110},
      {'name': 'Khoai lang', 'icon': '🍠', 'cal': 86},
      {'name': 'Bánh mì', 'icon': '🍞', 'cal': 265},
      {'name': 'Bún tươi', 'icon': '🍜', 'cal': 110},
      {'name': 'Khoai tây', 'icon': '🥔', 'cal': 77},
      {'name': 'Yến mạch', 'icon': '🥣', 'cal': 389},
      {'name': 'Ngô luộc', 'icon': '🌽', 'cal': 96},
    ],
  };

  final List<Map<String, dynamic>> _selectedFoods = [];

  void _toggleFood(Map<String, dynamic> food) {
    setState(() {
      if (_selectedFoods.contains(food)) {
        _selectedFoods.remove(food);
      } else {
        _selectedFoods.add(food);
      }
    });
  }

  double get _totalCalories => _selectedFoods.fold(0, (sum, item) => sum + item['cal']);

  String _getAdvice(double bmi) {
    if (_selectedFoods.isEmpty) return "Hãy chọn thực phẩm để xây dựng thực đơn!";
    if (bmi > 25 && _totalCalories > 500) return "⚠️ BMI cao, thực đơn này hơi nhiều năng lượng cho 1 bữa.";
    if (bmi < 18.5 && _totalCalories < 300) return "💪 BMI thấp, bạn cần bổ sung thêm đạm và tinh bột.";
    return "✅ Thực đơn cân bằng, phù hợp với bạn.";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: DatabaseHelper.instance.onDbUpdate,
      builder: (context, snapshot) {
        return FutureBuilder<List<HealthRecord>>(
          future: DatabaseHelper.instance.getAllRecords(),
          builder: (context, snapshot) {
            final records = snapshot.data ?? [];
            final userBMI = records.isNotEmpty ? records.last.bmi : 22.5;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Thực đơn cá nhân (100g/phần)'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => setState(() => _selectedFoods.clear()),
                  )
                ],
              ),
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C7A7B).withOpacity(0.05),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đã chọn: ${_selectedFoods.length} món',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C7A7B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_totalCalories.toStringAsFixed(0)} kcal',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18, color: Color(0xFF2C7A7B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getAdvice(userBMI),
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(15),
                      children: _foodCategories.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20, bottom: 10, left: 5),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C7A7B),
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: entry.value.length,
                              itemBuilder: (context, index) {
                                final food = entry.value[index];
                                final isSelected = _selectedFoods.contains(food);
                                return InkWell(
                                  onTap: () => _toggleFood(food),
                                  borderRadius: BorderRadius.circular(15),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF2C7A7B) : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF2C7A7B) : Colors.grey.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Text(food['icon'], style: const TextStyle(fontSize: 24)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  food['name'],
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected ? Colors.white : Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${food['cal']} kcal',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

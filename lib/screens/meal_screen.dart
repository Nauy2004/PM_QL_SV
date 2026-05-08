import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/health_record.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final List<Map<String, dynamic>> _selectedFoods = [];

  final Map<String, List<Map<String, dynamic>>> _foodCategories = {
    'Rau củ (100g)': [
      {'name': 'Bông cải xanh', 'icon': '🥦', 'cal': 34},
      {'name': 'Cà rốt', 'icon': '🥕', 'cal': 41},
      {'name': 'Rau muống', 'icon': '🥗', 'cal': 19},
      {'name': 'Bí đỏ', 'icon': '🎃', 'cal': 26},
      {'name': 'Cà chua', 'icon': '🍅', 'cal': 18},
    ],
    'Trái cây (100g)': [
      {'name': 'Táo', 'icon': '🍎', 'cal': 52},
      {'name': 'Chuối', 'icon': '🍌', 'cal': 88},
      {'name': 'Bơ', 'icon': '🥑', 'cal': 160},
    ],
    'Thịt & Đạm (100g)': [
      {'name': 'Ức gà', 'icon': '🍗', 'cal': 165},
      {'name': 'Thịt bò', 'icon': '🥩', 'cal': 250},
      {'name': 'Trứng (2 quả)', 'icon': '🥚', 'cal': 155},
      {'name': 'Cá hồi', 'icon': '🐟', 'cal': 208},
    ],
    'Tinh bột (100g)': [
      {'name': 'Cơm trắng', 'icon': '🍚', 'cal': 130},
      {'name': 'Gạo lứt', 'icon': '🌾', 'cal': 110},
      {'name': 'Khoai lang', 'icon': '🍠', 'cal': 86},
      {'name': 'Bánh mì', 'icon': '🍞', 'cal': 265},
    ],
  };

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
    if (bmi > 25 && _totalCalories > 500) return "⚠️ BMI cao, thực đơn này hơi nhiều năng lượng.";
    if (bmi < 18.5 && _totalCalories < 300) return "💪 BMI thấp, bạn cần bổ sung thêm dinh dưỡng.";
    return "✅ Thực đơn cân bằng cho sức khỏe của bạn.";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HealthRecord>>(
      stream: _firebaseService.getRecordsStream(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        final userBMI = records.isNotEmpty ? records.last.bmi : 22.5;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Thực đơn Cloud'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
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
                        Text('BMI mây: ${userBMI.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_totalCalories.toStringAsFixed(0)} kcal', style: const TextStyle(color: Color(0xFF2C7A7B), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_getAdvice(userBMI), style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
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
                          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
                          child: Text(entry.key, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2C7A7B))),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            final food = entry.value[index];
                            final isSelected = _selectedFoods.contains(food);
                            return GestureDetector(
                              onTap: () => _toggleFood(food),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2C7A7B) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? const Color(0xFF2C7A7B) : Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(food['icon'], style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      food['name'],
                                      style: TextStyle(
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
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
  }
}

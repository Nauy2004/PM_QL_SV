import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodInjector {
  static Future<void> injectDummyFoods(BuildContext context) async {
    // Danh sách 30 thực phẩm Việt Nam chia đều cho các danh mục không cần ảnh
    final List<Map<String, dynamic>> foodList = [
      // --- 1. DANH MỤC: THỊT (5 món) ---
      {
        "name": "Ức gà nướng phi lê",
        "calories": 165,
        "category": "Bữa chính",
        "type": "Thịt",
        "bmiTarget": "Obese",
        "image": ""
      },
      {
        "name": "Thịt bò thăn áp chảo",
        "calories": 250,
        "category": "Bữa chính",
        "type": "Thịt",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Thịt lợn nạc luộc",
        "calories": 240,
        "category": "Bữa chính",
        "type": "Thịt",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Thịt ba chỉ rang cháy cạnh",
        "calories": 540,
        "category": "Bữa chính",
        "type": "Thịt",
        "bmiTarget": "Underweight",
        "image": ""
      },
      {
        "name": "Chân giò hầm thuốc bắc",
        "calories": 450,
        "category": "Bữa chính",
        "type": "Thịt",
        "bmiTarget": "Underweight",
        "image": ""
      },

      // --- 2. DANH MỤC: CÁ (5 món) ---
      {
        "name": "Cá hồi hấp xì dầu",
        "calories": 200,
        "category": "Bữa chính",
        "type": "Cá",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Cá thu sốt cà chua",
        "calories": 320,
        "category": "Bữa chính",
        "type": "Cá",
        "bmiTarget": "Underweight",
        "image": ""
      },
      {
        "name": "Cá lóc nướng trui",
        "calories": 150,
        "category": "Bữa chính",
        "type": "Cá",
        "bmiTarget": "Overweight",
        "image": ""
      },
      {
        "name": "Cá ngừ đại dương áp chảo",
        "calories": 130,
        "category": "Bữa chính",
        "type": "Cá",
        "bmiTarget": "Obese",
        "image": ""
      },
      {
        "name": "Cá chép om dưa",
        "calories": 220,
        "category": "Bữa chính",
        "type": "Cá",
        "bmiTarget": "Normal",
        "image": ""
      },

      // --- 3. DANH MỤC: RAU (5 món) ---
      {
        "name": "Bông cải xanh luộc",
        "calories": 35,
        "category": "Bữa phụ",
        "type": "Rau",
        "bmiTarget": "Obese",
        "image": ""
      },
      {
        "name": "Rau muống xào tỏi",
        "calories": 85,
        "category": "Bữa chính",
        "type": "Rau",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Xà lách trộn dầu giấm",
        "calories": 50,
        "category": "Bữa phụ",
        "type": "Rau",
        "bmiTarget": "Overweight",
        "image": ""
      },
      {
        "name": "Rau ngót nấu thịt băm",
        "calories": 110,
        "category": "Bữa chính",
        "type": "Rau",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Măng tây xào nấm",
        "calories": 65,
        "category": "Bữa chính",
        "type": "Rau",
        "bmiTarget": "Obese",
        "image": ""
      },

      // --- 4. DANH MỤC: HOA QUẢ (5 món) ---
      {
        "name": "Quả Táo tươi ngon",
        "calories": 52,
        "category": "Bữa phụ",
        "type": "Hoa quả",
        "bmiTarget": "Overweight",
        "image": ""
      },
      {
        "name": "Quả Chuối tiêu chín",
        "calories": 89,
        "category": "Bữa phụ",
        "type": "Hoa quả",
        "bmiTarget": "Underweight",
        "image": ""
      },
      {
        "name": "Bơ sáp Đắk Lắk nguyên quả",
        "calories": 160,
        "category": "Bữa phụ",
        "type": "Hoa quả",
        "bmiTarget": "Underweight",
        "image": ""
      },
      {
        "name": "Dưa hấu đỏ Nam Bộ",
        "calories": 30,
        "category": "Bữa phụ",
        "type": "Hoa quả",
        "bmiTarget": "Obese",
        "image": ""
      },
      {
        "name": "Quả Bưởi da xanh",
        "calories": 38,
        "category": "Bữa phụ",
        "type": "Hoa quả",
        "bmiTarget": "Obese",
        "image": ""
      },

      // --- 5. DANH MỤC: HẢI SẢN (5 món) ---
      {
        "name": "Tôm sú hấp sả",
        "calories": 95,
        "category": "Bữa chính",
        "type": "Hải sản",
        "bmiTarget": "Obese",
        "image": ""
      },
      {
        "name": "Mực ống nướng sa tế",
        "calories": 140,
        "category": "Bữa chính",
        "type": "Hải sản",
        "bmiTarget": "Overweight",
        "image": ""
      },
      {
        "name": "Nghêu hấp thái",
        "calories": 75,
        "category": "Bữa phụ",
        "type": "Hải sản",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Cua biển hấp chấm muối tiêu",
        "calories": 120,
        "category": "Bữa chính",
        "type": "Hải sản",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Hàu sữa nướng mỡ hành",
        "calories": 250,
        "category": "Bữa phụ",
        "type": "Hải sản",
        "bmiTarget": "Underweight",
        "image": ""
      },

      // --- 6. DANH MỤC: TINH BỘT (5 món) ---
      {
        "name": "Gạo lứt huyết rồng luộc",
        "calories": 110,
        "category": "Bữa chính",
        "type": "Tinh bột",
        "bmiTarget": "Overweight",
        "image": ""
      },
      {
        "name": "Cơm trắng truyền thống",
        "calories": 130,
        "category": "Bữa chính",
        "type": "Tinh bột",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Khoai lang mật nướng",
        "calories": 86,
        "category": "Bữa phụ",
        "type": "Tinh bột",
        "bmiTarget": "Obese",
        "image": ""
      },
      {
        "name": "Bánh mì gối nguyên cám",
        "calories": 250,
        "category": "Bữa sáng",
        "type": "Tinh bột",
        "bmiTarget": "Normal",
        "image": ""
      },
      {
        "name": "Xôi xéo mỡ hành ruốc",
        "calories": 600,
        "category": "Bữa sáng",
        "type": "Tinh bột",
        "bmiTarget": "Underweight",
        "image": ""
      },
    ];

    try {
      final CollectionReference foodsRef = FirebaseFirestore.instance.collection('foods');

      // Tạo một Batch ghi dữ liệu đồng loạt lên Firestore cho nhanh và tiết kiệm tài nguyên
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var food in foodList) {
        DocumentReference docRef = foodsRef.doc(); // Tự động tạo mã ID Document ngẫu nhiên
        batch.set(docRef, food);
      }

      await batch.commit(); // Đẩy dữ liệu hàng loạt lên mây

      // Hiện SnackBar báo cho bạn biết đã hoàn thành tác vụ nhập liệu
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Đã khởi tạo thành công 30 thực phẩm lên Firebase Firestore!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xảy ra lỗi khi nạp dữ liệu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import '../domain/models/meal.dart';

class ApiService {
  // Bộ Key Tuấn vừa lấy (Gói Minimum Service - Food Database)
  final String appId = 'a86e63f2';
  final String appKey = '172bb562b4188b8b3430944a2f997f33';

  final translator = GoogleTranslator();

  // 1. Gợi ý dựa trên BMI
  Future<List<Meal>> fetchSuggestedMeals(double bmi) async {
    String query = bmi < 18.5 ? "egg milk meat" : (bmi > 24.9 ? "salad vegetable" : "rice chicken");
    return _callFoodDatabaseAPI(query);
  }

  // 2. Tìm kiếm thực phẩm
  Future<List<Meal>> searchFoods(String query) async {
    var translation = await translator.translate(query, from: 'vi', to: 'en');
    return _callFoodDatabaseAPI(translation.text);
  }

  // HÀM GỌI ĐÚNG ENDPOINT FOOD-DATABASE
  Future<List<Meal>> _callFoodDatabaseAPI(String q) async {
    try {
      // Endpoint dành cho gói Minimum Service của Tuấn
      final String url = "https://api.edamam.com/api/food-database/v2/parser?app_id=$appId&app_key=$appKey&ingr=$q";

      print("--- Đang gọi Food API: $q ---");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cấu trúc JSON của Food Database khác với Recipe Search
        List hints = data['hints'] ?? [];
        List<Meal> results = [];

        for (var item in hints) {
          final food = item['food'];
          var viTitle = await translator.translate(food['label'], from: 'en', to: 'vi');

          results.add(Meal(
            name: viTitle.text,
            // Food Database trả về calo trong mục nutrients
            calories: "${(food['nutrients']['ENERC_KCAL'] ?? 0).toInt()} kcal",
            image: food['image'] ?? 'https://via.placeholder.com/150',
            category: food['category'] ?? 'THỰC PHẨM',
          ));
        }
        print("--- Đã thấy ${results.length} thực phẩm ---");
        return results;
      } else {
        print("--- Lỗi API: ${response.statusCode} ---");
        return [];
      }
    } catch (e) {
      print("--- Lỗi kết nối: $e ---");
      return [];
    }
  }
}
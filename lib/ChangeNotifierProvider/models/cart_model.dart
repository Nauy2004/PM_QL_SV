import 'package:flutter/foundation.dart';

/// Model quản lý giỏ hàng — dùng cho demo Provider
/// Gọi notifyListeners() để tất cả widget đang lắng nghe tự rebuild
class CartModel extends ChangeNotifier {
  final List<String> _items = [];

  List<String> get items => List.unmodifiable(_items);
  int get count => _items.length;
  int get totalPrice => _items.length * 150000;

  void addItem(String name) {
    _items.add(name);
    notifyListeners(); // ← quan trọng: báo cho Consumer rebuild
  }

  void removeItem(String name) {
    _items.remove(name);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
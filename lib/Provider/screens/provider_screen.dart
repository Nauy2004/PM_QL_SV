import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ChangeNotifierProvider/models/cart_model.dart';
import '_demo_scaffold.dart';

// ─── Các widget độc lập, cùng dùng CartModel ────────────────────────────────

/// Badge số lượng giỏ hàng — rebuild khi CartModel thay đổi
class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch → lắng nghe thay đổi, widget tự rebuild
    final count = context.watch<CartModel>().count;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: count > 0
            ? const Color(0xFFFF9500).withOpacity(0.12)
            : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: count > 0
              ? const Color(0xFFFF9500).withOpacity(0.4)
              : const Color(0xFFE5E5EA),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 16,
            color: count > 0 ? const Color(0xFFFF9500) : const Color(0xFF8E8E93),
          ),
          const SizedBox(width: 6),
          Text(
            count > 0 ? '$count sản phẩm' : 'Giỏ trống',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: count > 0
                  ? const Color(0xFFFF9500)
                  : const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tổng tiền — widget khác, cũng rebuild khi CartModel thay đổi
class PriceSummary extends StatelessWidget {
  const PriceSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9500).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFFF9500).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tổng thanh toán',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                SizedBox(height: 2),
                Text('PriceSummary (Consumer)',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAEAEB2),
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Text(
            cart.count == 0
                ? '0 ₫'
                : '${(cart.totalPrice / 1000).round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}k ₫',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF9500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Danh sách sản phẩm trong giỏ
class CartItemList extends StatelessWidget {
  const CartItemList({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer<T> là cú pháp khác của context.watch
    return Consumer<CartModel>(
      builder: (context, cart, _) {
        if (cart.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Thêm sản phẩm bên dưới',
                style: TextStyle(fontSize: 13, color: Color(0xFFAEAEB2)),
              ),
            ),
          );
        }
        return Column(
          children: cart.items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: const Color(0xFFE5E5EA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 16, color: Color(0xFF8E8E93)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1C1C1E))),
                          ),
                          GestureDetector(
                            onTap: () =>
                                context.read<CartModel>().removeItem(item),
                            child: const Icon(Icons.close_rounded,
                                size: 16, color: Color(0xFFAEAEB2)),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Screen ────────────────────────────────────────────────────────────────

class ProviderScreen extends StatelessWidget {
  const ProviderScreen({super.key});

  static const _products = [
    'iPhone 15 Pro',
    'AirPods Pro',
    'MacBook Air',
    'iPad Mini',
    'Apple Watch',
  ];

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Provider / ChangeNotifier',
      color: const Color(0xFFFF9500),
      explanation:
          'CartModel được cung cấp ở main.dart qua ChangeNotifierProvider. '
          'CartBadge, PriceSummary và CartItemList là 3 widget độc lập — tất cả tự rebuild '
          'khi CartModel.notifyListeners() được gọi.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget 1: CartBadge (ở trên cùng như navbar)
          Row(
            children: [
              const Text('NavBar:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
              const SizedBox(width: 8),
              const CartBadge(),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.read<CartModel>().clear(),
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('Xóa hết', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF3B30)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Widget 2: PriceSummary
          const PriceSummary(),
          const SizedBox(height: 16),
          const Text(
            'GIỎ HÀNG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          // Widget 3: CartItemList
          const CartItemList(),
          const SizedBox(height: 16),
          const Text(
            'THÊM SẢN PHẨM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _products
                .map((p) => ActionChip(
                      label: Text(p, style: const TextStyle(fontSize: 12)),
                      onPressed: () => context.read<CartModel>().addItem(p),
                      avatar: const Icon(Icons.add, size: 14),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE5E5EA)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
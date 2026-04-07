import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _demos = [
    _DemoItem(
      route: '/constructor',
      title: 'Constructor Props',
      subtitle: 'Cha truyền data xuống Con qua tham số',
      icon: Icons.arrow_downward_rounded,
      color: Color(0xFF34C759),
      tag: 'Dễ · Cha → Con',
    ),
    _DemoItem(
      route: '/callback',
      title: 'Callback Function',
      subtitle: 'Con gửi data ngược lên Cha qua hàm callback',
      icon: Icons.arrow_upward_rounded,
      color: Color(0xFF007AFF),
      tag: 'Dễ · Con → Cha',
    ),
    _DemoItem(
      route: '/provider',
      title: 'Provider / ChangeNotifier',
      subtitle: 'Shared state cho toàn bộ widget tree',
      icon: Icons.share_rounded,
      color: Color(0xFFFF9500),
      tag: 'Phổ biến · Shared',
    ),
    _DemoItem(
      route: '/stream',
      title: 'StreamController',
      subtitle: 'Luồng dữ liệu bất đồng bộ real-time',
      icon: Icons.stream_rounded,
      color: Color(0xFFFF3B30),
      tag: 'Nâng cao · Async',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5856D6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Flutter Web Demo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5856D6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Truyền dữ liệu\ngiữa các Widget',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '4 phương pháp phổ biến nhất trong Flutter.\nChọn một demo để bắt đầu.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF8E8E93),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DemoCard(item: _demos[i]),
                      ),
                      childCount: _demos.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final _DemoItem item;
  const _DemoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, item.route),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: item.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade300, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoItem {
  final String route, title, subtitle, tag;
  final IconData icon;
  final Color color;

  const _DemoItem({
    required this.route,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tag,
  });
}
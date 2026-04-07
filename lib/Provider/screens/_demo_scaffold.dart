import 'package:flutter/material.dart';

/// Scaffold dùng chung cho tất cả demo screen.
/// Cung cấp AppBar, màu sắc nhất quán, và khung giải thích.
class DemoScaffold extends StatelessWidget {
  final String title;
  final Color color;
  final String explanation;
  final Widget child;

  const DemoScaffold({
    super.key,
    required this.title,
    required this.color,
    required this.explanation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF1C1C1E),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 0.5,
            color: const Color(0xFFE5E5EA),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ô giải thích
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: color.withOpacity(0.85),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Nội dung demo
                child,
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
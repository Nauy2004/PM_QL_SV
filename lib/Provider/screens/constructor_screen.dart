import 'package:flutter/material.dart';
import '_demo_scaffold.dart';

// ─── Widget Con: nhận data qua constructor ───────────────────────────────────

class ScoreCard extends StatelessWidget {
  final String playerName; // bắt buộc truyền vào
  final int score;
  final Color color;

  const ScoreCard({
    super.key,
    required this.playerName,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            playerName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget Cha: giữ state, truyền xuống Con ────────────────────────────────

class ConstructorScreen extends StatefulWidget {
  const ConstructorScreen({super.key});

  @override
  State<ConstructorScreen> createState() => _ConstructorScreenState();
}

class _ConstructorScreenState extends State<ConstructorScreen> {
  int _scoreA = 72;
  int _scoreB = 45;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Constructor Props',
      color: const Color(0xFF34C759),
      explanation:
          'ParentWidget giữ state (_scoreA, _scoreB). Mỗi khi slider thay đổi, '
          'setState() được gọi và ScoreCard rebuild với giá trị mới được truyền qua constructor.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Controls ở widget cha
          const _SectionLabel('Widget Cha (giữ state)'),
          const SizedBox(height: 12),
          _SliderRow(
            label: 'Điểm người chơi A',
            value: _scoreA,
            color: const Color(0xFF34C759),
            onChanged: (v) => setState(() => _scoreA = v),
          ),
          const SizedBox(height: 8),
          _SliderRow(
            label: 'Điểm người chơi B',
            value: _scoreB,
            color: const Color(0xFF007AFF),
            onChanged: (v) => setState(() => _scoreB = v),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Widget Con (nhận qua constructor)'),
          const SizedBox(height: 12),
          // Truyền data xuống qua constructor
          Row(
            children: [
              Expanded(
                child: ScoreCard(
                  playerName: 'Người chơi A',
                  score: _scoreA, // ← truyền xuống
                  color: const Color(0xFF34C759),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ScoreCard(
                  playerName: 'Người chơi B',
                  score: _scoreB, // ← truyền xuống
                  color: const Color(0xFF007AFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _CodeBox(
            'ScoreCard(\n'
            '  playerName: "Người chơi A",\n'
            '  score: \$_scoreA,  // ← từ parent state\n'
            '  color: Colors.green,\n'
            ')',
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
              Slider(
                value: value.toDouble(),
                min: 0,
                max: 100,
                activeColor: color,
                onChanged: (v) => onChanged(v.round()),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8E8E93),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  final String code;
  const _CodeBox(this.code);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFF98C379),
          height: 1.6,
        ),
      ),
    );
  }
}
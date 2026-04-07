import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '_demo_scaffold.dart';

// ─── Data model ─────────────────────────────────────────────────────────────

class SensorData {
  final double temperature;
  final double humidity;
  final DateTime time;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.time,
  });
}

// ─── Service: nguồn phát stream ─────────────────────────────────────────────

class SensorService {
  // broadcast() cho phép nhiều widget cùng lắng nghe
  final _controller = StreamController<SensorData>.broadcast();
  Timer? _timer;
  final _random = Random();

  Stream<SensorData> get stream => _controller.stream;
  bool get isRunning => _timer != null;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _controller.add(SensorData(
        temperature: 20 + _random.nextDouble() * 15, // 20–35°C
        humidity: 40 + _random.nextDouble() * 40,    // 40–80%
        time: DateTime.now(),
      ));
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close(); // luôn đóng controller khi xong
  }
}

// ─── Widget hiển thị giá trị realtime ───────────────────────────────────────

class SensorGauge extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min, max;
  final Color color;
  final IconData icon;

  const SensorGauge({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(unit,
                  style: TextStyle(
                      fontSize: 14, color: color.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class StreamScreen extends StatefulWidget {
  const StreamScreen({super.key});

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  final _service = SensorService();
  final List<SensorData> _history = [];
  bool _running = false;

  @override
  void dispose() {
    _service.dispose(); // quan trọng: đóng stream khi widget bị remove
    super.dispose();
  }

  void _toggle() {
    setState(() => _running = !_running);
    _running ? _service.start() : _service.stop();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'StreamController',
      color: const Color(0xFFFF3B30),
      explanation:
          'SensorService dùng StreamController.broadcast() để phát data mỗi giây. '
          'StreamBuilder lắng nghe stream và rebuild mỗi khi có snapshot mới. '
          'Nhớ gọi controller.close() trong dispose() để tránh memory leak.',
      child: Column(
        children: [
          // Control row
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _running
                      ? const Color(0xFF34C759)
                      : const Color(0xFFAEAEB2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _running ? 'Đang nhận dữ liệu...' : 'Stream chưa bắt đầu',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      _running ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _toggle,
                icon: Icon(_running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 16),
                label: Text(_running ? 'Dừng' : 'Bắt đầu'),
                style: FilledButton.styleFrom(
                  backgroundColor: _running
                      ? const Color(0xFFFF3B30)
                      : const Color(0xFF34C759),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // StreamBuilder — widget tự rebuild theo stream
          StreamBuilder<SensorData>(
            stream: _service.stream,
            builder: (context, snapshot) {
              // Lưu lịch sử
              if (snapshot.hasData && snapshot.data != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _history.insert(0, snapshot.data!);
                    if (_history.length > 8) _history.removeLast();
                  });
                });
              }

              if (!snapshot.hasData) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sensors_off_outlined,
                            color: Color(0xFFAEAEB2), size: 28),
                        SizedBox(height: 8),
                        Text('Nhấn Bắt đầu để nhận data',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFFAEAEB2))),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data!;
              return Row(
                children: [
                  Expanded(
                    child: SensorGauge(
                      label: 'Nhiệt độ',
                      value: data.temperature,
                      unit: '°C',
                      min: 20,
                      max: 35,
                      color: const Color(0xFFFF3B30),
                      icon: Icons.thermostat_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SensorGauge(
                      label: 'Độ ẩm',
                      value: data.humidity,
                      unit: '%',
                      min: 40,
                      max: 80,
                      color: const Color(0xFF007AFF),
                      icon: Icons.water_drop_outlined,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Lịch sử events
          Row(
            children: [
              const Text(
                'LỊCH SỬ EVENTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              if (_history.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_history.length}',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (_history.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Chưa có events',
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFFAEAEB2)),
                ),
              ),
            )
          else
            ..._history.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${d.time.hour.toString().padLeft(2, '0')}:${d.time.minute.toString().padLeft(2, '0')}:${d.time.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.thermostat_rounded,
                            size: 12,
                            color: const Color(0xFFFF3B30).withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          '${d.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.water_drop_outlined,
                            size: 12,
                            color: const Color(0xFF007AFF).withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          '${d.humidity.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
  import 'package:flutter/material.dart';
import '_demo_scaffold.dart';

// ─── Widget Con: có form, gọi callback để gửi data lên cha ──────────────────

class MessageForm extends StatefulWidget {
  final void Function(String message, String author) onSubmit; // callback

  const MessageForm({super.key, required this.onSubmit});

  @override
  State<MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final _msgController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final msg = _msgController.text.trim();
    final author = _authorController.text.trim();
    if (msg.isEmpty) return;

    // Gọi callback → data đi lên Widget Cha
    widget.onSubmit(msg, author.isEmpty ? 'Ẩn danh' : author);

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MessageForm (Widget Con)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _authorController,
            decoration: _inputDecoration('Tên của bạn (tùy chọn)'),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _msgController,
            decoration: _inputDecoration('Nhập tin nhắn...'),
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            onSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Gửi lên Widget Cha'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAEAEB2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF007AFF), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      );
}

// ─── Widget Cha: nhận callback, lưu danh sách tin nhắn ─────────────────────

class CallbackScreen extends StatefulWidget {
  const CallbackScreen({super.key});

  @override
  State<CallbackScreen> createState() => _CallbackScreenState();
}

class _CallbackScreenState extends State<CallbackScreen> {
  final List<_Msg> _messages = [];

  // Hàm này được truyền xuống con như callback
  void _onMessageReceived(String message, String author) {
    setState(() {
      _messages.insert(0, _Msg(
        text: message,
        author: author,
        time: TimeOfDay.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Callback Function',
      color: const Color(0xFF007AFF),
      explanation:
          'Widget Cha truyền hàm _onMessageReceived xuống con. Khi người dùng submit, '
          'con gọi widget.onSubmit(msg, author) → dữ liệu đi ngược lên cha, setState() cập nhật danh sách.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget Con ở trên
          MessageForm(onSubmit: _onMessageReceived),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'WIDGET CHA NHẬN ĐƯỢC',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              if (_messages.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_messages.length}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_messages.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Chưa có tin nhắn nào.\nGửi một tin để xem callback hoạt động.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                ),
              ),
            )
          else
            ...List.generate(
              _messages.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MessageBubble(msg: _messages[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text, author;
  final TimeOfDay time;
  _Msg({required this.text, required this.author, required this.time});
}

class _MessageBubble extends StatelessWidget {
  final _Msg msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF007AFF).withOpacity(0.12),
            child: Text(
              msg.author[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      msg.author,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAEAEB2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  msg.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3C3C43),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
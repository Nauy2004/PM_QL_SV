class HealthRecord {
  final int? id;
  final double weight;
  final double height;
  final double bmi;
  final String category;
  final DateTime createdAt;
  final String? note;

  HealthRecord({
    this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.category,
    required this.createdAt,
    this.note,
  });

  // Chuyển đổi sang Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'note': note,
    };
  }

  // Khởi tạo từ Map (khi đọc từ SQLite)
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      weight: map['weight'],
      height: map['height'],
      bmi: map['bmi'],
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
      note: map['note'],
    );
  }
}

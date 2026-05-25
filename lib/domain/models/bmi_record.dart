import 'package:cloud_firestore/cloud_firestore.dart';

class BmiRecord {
  final String id;
  final double weight;
  final double height;
  final double bmi;
  final DateTime timestamp;
  final String status;

  BmiRecord({
    required this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.timestamp,
    required this.status,
  });

  factory BmiRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BmiRecord(
      id: doc.id,
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      bmi: (data['bmi'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'timestamp': timestamp,
      'status': status,
    };
  }

  static String interpretBmi(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}

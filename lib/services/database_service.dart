import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/bmi_record.dart';
import '../domain/models/user_profile.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // --- BMI History ---
  Future<void> saveBmiRecord(double weight, double height, double bmi) async {
    String status = BmiRecord.interpretBmi(bmi);
    await usersCollection.doc(uid).collection('bmi_history').add({
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status,
    });
  }

  Stream<List<BmiRecord>> get bmiHistory {
    return usersCollection
        .doc(uid)
        .collection('bmi_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BmiRecord.fromFirestore(doc);
      }).toList();
    });
  }

  // --- User Profile ---
  Future<void> updateUserData(String name, int age, double goalWeight) async {
    await usersCollection.doc(uid).set({
      'name': name,
      'age': age,
      'goalWeight': goalWeight,
    }, SetOptions(merge: true));
  }

  Stream<UserProfile> get userData {
    return usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(uid, doc.data() as Map<String, dynamic>);
      }
      return UserProfile(uid: uid, name: '', age: 0, goalWeight: 0.0);
    });
  }

  // --- Meal Planning ---
  Future<void> savePlannedMeal(String name, String calories, String category) async {
    await usersCollection.doc(uid).collection('meals').add({
      'name': name,
      'calories': calories,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> get todayCaloriesIn {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    
    return usersCollection
        .doc(uid)
        .collection('meals')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            String calStr = doc['calories'].toString().replaceAll(RegExp(r'[^0-9]'), '');
            total += int.tryParse(calStr) ?? 0;
          }
          return total;
        });
  }

  // --- Workout Tracking ---
  Future<void> logWorkout(String name, int caloriesBurned) async {
    await usersCollection.doc(uid).collection('workout_logs').add({
      'workoutName': name,
      'caloriesBurned': caloriesBurned,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> get todayCaloriesBurned {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return usersCollection
        .doc(uid)
        .collection('workout_logs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            total += (doc['caloriesBurned'] as num).toInt();
          }
          return total;
        });
  }
}

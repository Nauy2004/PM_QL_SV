import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/health_record.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Auth ---
  Future<User?> signUp(String email, String password) async {
    final res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return res.user;
  }

  Future<User?> signIn(String email, String password) async {
    final res = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return res.user;
  }

  void signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  // --- Firestore Records ---
  Future<void> addRecord(HealthRecord record) async {
    if (currentUser == null) return;
    
    await _db.collection('users').doc(currentUser!.uid).collection('records').add({
      'weight': record.weight,
      'height': record.height,
      'bmi': record.bmi,
      'category': record.category,
      'created_at': record.createdAt.toIso8601String(),
      'note': record.note,
    });
  }

  Stream<List<HealthRecord>> getRecordsStream() {
    if (currentUser == null) return Stream.value([]);
    
    return _db
        .collection('users')
        .doc(currentUser!.uid)
        .collection('records')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return HealthRecord(
                weight: data['weight'],
                height: data['height'],
                bmi: data['bmi'],
                category: data['category'],
                createdAt: DateTime.parse(data['created_at']),
                note: data['note'],
              );
            }).toList());
  }
}

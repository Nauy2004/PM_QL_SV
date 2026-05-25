class UserProfile {
  final String uid;
  final String name;
  final int age;
  final double goalWeight;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.goalWeight,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'goalWeight': goalWeight,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      goalWeight: (data['goalWeight'] ?? 0).toDouble(),
    );
  }
}

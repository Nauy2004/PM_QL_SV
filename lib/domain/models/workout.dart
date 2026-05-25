class Workout {
  final String name;
  final int caloriesPerMinute;
  final String duration;
  bool isCompleted;

  Workout({
    required this.name,
    required this.caloriesPerMinute,
    required this.duration,
    this.isCompleted = false,
  });
}

List<Workout> defaultWorkouts = [
  Workout(name: 'Running', caloriesPerMinute: 10, duration: '30 mins'),
  Workout(name: 'Cycling', caloriesPerMinute: 8, duration: '45 mins'),
  Workout(name: 'Yoga', caloriesPerMinute: 4, duration: '20 mins'),
  Workout(name: 'Weight Lifting', caloriesPerMinute: 6, duration: '40 mins'),
];

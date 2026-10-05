class FitnessGoal {
  final int id;
  final int steps;
  final double calories;
  final int workoutMinutes;
  final double distance;

  FitnessGoal({
    this.id = 1,
    this.steps = 10000,
    this.calories = 700.0,
    this.workoutMinutes = 60,
    this.distance = 5.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'steps': steps,
      'calories': calories,
      'workoutMinutes': workoutMinutes,
      'distance': distance,
    };
  }

  factory FitnessGoal.fromMap(Map<String, dynamic> map) {
    return FitnessGoal(
      id: map['id'] as int? ?? 1,
      steps: (map['steps'] as num?)?.toInt() ?? 10000,
      calories: (map['calories'] as num?)?.toDouble() ?? 700.0,
      workoutMinutes: (map['workoutMinutes'] as num?)?.toInt() ?? 60,
      distance: (map['distance'] as num?)?.toDouble() ?? 5.0,
    );
  }

  FitnessGoal copyWith({
    int? id,
    int? steps,
    double? calories,
    int? workoutMinutes,
    double? distance,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      workoutMinutes: workoutMinutes ?? this.workoutMinutes,
      distance: distance ?? this.distance,
    );
  }
}

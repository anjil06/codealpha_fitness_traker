class Activity {
  final int? id;
  final String exerciseType;
  final int duration; // in minutes
  final double calories; // kcal
  final double? distance; // in km
  final int? steps;
  final String date; // format: 'YYYY-MM-DD'
  final String? time; // format: '06:30 PM'
  final String? notes;

  Activity({
    this.id,
    required this.exerciseType,
    required this.duration,
    required this.calories,
    this.distance,
    this.steps,
    required this.date,
    this.time,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'exerciseType': exerciseType,
      'duration': duration,
      'calories': calories,
      'distance': distance,
      'steps': steps,
      'date': date,
      'time': time,
      'notes': notes,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as int?,
      exerciseType: map['exerciseType'] as String? ?? 'Other',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      distance: (map['distance'] as num?)?.toDouble(),
      steps: (map['steps'] as num?)?.toInt(),
      date: map['date'] as String? ?? '',
      time: map['time'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Activity copyWith({
    int? id,
    String? exerciseType,
    int? duration,
    double? calories,
    double? distance,
    int? steps,
    String? date,
    String? time,
    String? notes,
  }) {
    return Activity(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      distance: distance ?? this.distance,
      steps: steps ?? this.steps,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
    );
  }
}

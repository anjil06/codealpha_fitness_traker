import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'FitTrack';
  static const String appTagline = 'Track. Move. Improve.';
  static const String appVersion = '1.0.2';

  // Shared Preferences keys
  static const String keyUserName = 'user_name';
  static const String defaultUserName = 'Anjil';

  // Exercise Types
  static const String running = 'Running';
  static const String walking = 'Walking';
  static const String cycling = 'Cycling';
  static const String swimming = 'Swimming';
  static const String gym = 'Gym';
  static const String strengthTraining = 'Strength Training';
  static const String yoga = 'Yoga';
  static const String hiit = 'HIIT';
  static const String sports = 'Sports';
  static const String other = 'Other';

  static const List<String> exerciseTypes = [
    running,
    walking,
    cycling,
    swimming,
    gym,
    strengthTraining,
    yoga,
    hiit,
    sports,
    other,
  ];

  /// Get appropriate icon for an exercise type
  static IconData getExerciseIcon(String type) {
    switch (type) {
      case running:
        return Icons.directions_run_rounded;
      case walking:
        return Icons.directions_walk_rounded;
      case cycling:
        return Icons.directions_bike_rounded;
      case swimming:
        return Icons.pool_rounded;
      case gym:
        return Icons.fitness_center_rounded;
      case strengthTraining:
        return Icons.sports_gymnastics_rounded;
      case yoga:
        return Icons.self_improvement_rounded;
      case hiit:
        return Icons.bolt_rounded;
      case sports:
        return Icons.sports_soccer_rounded;
      default:
        return Icons.local_fire_department_rounded;
    }
  }

  /// Get thematic color for an exercise type
  static Color getExerciseColor(String type) {
    switch (type) {
      case running:
        return const Color(0xFFFF6F00); // Deep Amber
      case walking:
        return const Color(0xFF4CAF50); // Green
      case cycling:
        return const Color(0xFF00ACC1); // Cyan
      case swimming:
        return const Color(0xFF1E88E5); // Blue
      case gym:
        return const Color(0xFFE53935); // Red
      case strengthTraining:
        return const Color(0xFF8E24AA); // Purple
      case yoga:
        return const Color(0xFF5E35B1); // Deep Purple
      case hiit:
        return const Color(0xFFF4511E); // Deep Orange
      case sports:
        return const Color(0xFF3949AB); // Indigo
      default:
        return const Color(0xFF546E7A); // Blue Grey
    }
  }

  /// Approximate calorie burn per minute for default estimation
  static double getEstimatedCaloriesPerMinute(String type) {
    switch (type) {
      case running:
        return 10.0;
      case walking:
        return 4.5;
      case cycling:
        return 8.5;
      case swimming:
        return 9.0;
      case gym:
        return 6.5;
      case strengthTraining:
        return 7.0;
      case yoga:
        return 3.5;
      case hiit:
        return 11.0;
      case sports:
        return 8.0;
      default:
        return 5.0;
    }
  }
}

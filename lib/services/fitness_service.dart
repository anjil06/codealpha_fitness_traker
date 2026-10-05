import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../utils/constants.dart';

class DaySummary {
  final DateTime date;
  final String dayLabel; // e.g. "Mon"
  final String dateString; // e.g. "2026-10-05"
  final int steps;
  final double calories;
  final int workoutMinutes;
  final double distance;

  DaySummary({
    required this.date,
    required this.dayLabel,
    required this.dateString,
    required this.steps,
    required this.calories,
    required this.workoutMinutes,
    required this.distance,
  });
}

class FitnessService {
  /// Calculate progress clamped between 0.0 and 1.0
  static double calculateProgress(num current, num goal) {
    if (goal <= 0) return 0.0;
    return math.min((current / goal).toDouble(), 1.0);
  }

  /// Calculate percentage as integer (0 to 100)
  static int calculatePercentage(num current, num goal) {
    return (calculateProgress(current, goal) * 100).round();
  }

  /// Get time-based greeting
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Formats date for dashboard header e.g. "Monday, October 5"
  static String formatHeaderDate(DateTime dt) {
    return DateFormat('EEEE, MMMM d').format(dt);
  }

  /// Formats date to 'yyyy-MM-dd' for database storage and comparisons
  static String formatDateKey(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  /// Formats relative date display: "Today", "Yesterday", or "Oct 5, 2026"
  static String formatDisplayDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final checkDate = DateTime(date.year, date.month, date.day);

      final diffDays = today.difference(checkDate).inDays;
      if (diffDays == 0) {
        return 'Today';
      } else if (diffDays == 1) {
        return 'Yesterday';
      } else if (diffDays > 1 && diffDays < 7) {
        return DateFormat('EEEE').format(date); // e.g. "Saturday"
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (_) {
      return dateStr;
    }
  }

  /// Aggregate last 7 days of activities
  static List<DaySummary> getWeeklySummaries(List<Activity> allActivities) {
    final now = DateTime.now();
    final List<DaySummary> summaries = [];

    // Last 7 days, ending today
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = formatDateKey(date);
      final dayLabel = DateFormat('E').format(date); // Mon, Tue, etc.

      final dayActivities = allActivities.where((a) => a.date == dateKey).toList();

      int steps = 0;
      double calories = 0.0;
      int workoutMinutes = 0;
      double distance = 0.0;

      for (final a in dayActivities) {
        steps += a.steps ?? 0;
        calories += a.calories;
        workoutMinutes += a.duration;
        distance += a.distance ?? 0.0;
      }

      summaries.add(DaySummary(
        date: date,
        dayLabel: dayLabel,
        dateString: dateKey,
        steps: steps,
        calories: calories,
        workoutMinutes: workoutMinutes,
        distance: distance,
      ));
    }

    return summaries;
  }

  /// Helper to estimate calories from workout type and duration
  static double estimateCalories(String exerciseType, int durationMinutes) {
    final rate = AppConstants.getEstimatedCaloriesPerMinute(exerciseType);
    return (rate * durationMinutes).roundToDouble();
  }
}

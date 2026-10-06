import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/fitness_goal.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  FitnessGoal _goal = FitnessGoal();
  bool _isLoading = false;

  FitnessGoal get goal => _goal;
  bool get isLoading => _isLoading;

  Future<void> loadGoal() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goal = await _dbHelper.getGoal();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alias for backward compatibility
  Future<void> loadGoalAndUser() => loadGoal();

  Future<bool> updateGoal({
    required int steps,
    required double calories,
    required int workoutMinutes,
    required double distance,
  }) async {
    try {
      final updated = _goal.copyWith(
        steps: steps,
        calories: calories,
        workoutMinutes: workoutMinutes,
        distance: distance,
      );
      await _dbHelper.updateGoal(updated);
      _goal = updated;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/fitness_goal.dart';
import '../utils/constants.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  FitnessGoal _goal = FitnessGoal();
  String _userName = AppConstants.defaultUserName;
  bool _isLoading = false;

  FitnessGoal get goal => _goal;
  String get userName => _userName;
  bool get isLoading => _isLoading;

  Future<void> loadGoalAndUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goal = await _dbHelper.getGoal();
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString(AppConstants.keyUserName) ?? AppConstants.defaultUserName;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> updateUserName(String newName) async {
    if (newName.trim().isEmpty) return;
    _userName = newName.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, _userName);
    notifyListeners();
  }
}

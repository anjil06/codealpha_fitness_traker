import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/activity.dart';
import '../services/fitness_service.dart';

class ActivityProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Today's Date in 'YYYY-MM-DD'
  String get todayDateKey => FitnessService.formatDateKey(DateTime.now());

  // Today's activities
  List<Activity> get todayActivities =>
      _activities.where((a) => a.date == todayDateKey).toList();

  // Today's Metrics
  int get todaySteps =>
      todayActivities.fold<int>(0, (sum, a) => sum + (a.steps ?? 0));

  double get todayCalories =>
      todayActivities.fold<double>(0.0, (sum, a) => sum + a.calories);

  int get todayDuration =>
      todayActivities.fold<int>(0, (sum, a) => sum + a.duration);

  double get todayDistance =>
      todayActivities.fold<double>(0.0, (sum, a) => sum + (a.distance ?? 0.0));

  // Recent activities (up to 5)
  List<Activity> get recentActivities {
    return _activities.take(5).toList();
  }

  // Weekly Aggregations
  List<DaySummary> get weeklySummaries =>
      FitnessService.getWeeklySummaries(_activities);

  int get weeklyTotalSteps =>
      weeklySummaries.fold<int>(0, (sum, day) => sum + day.steps);

  double get weeklyTotalCalories =>
      weeklySummaries.fold<double>(0.0, (sum, day) => sum + day.calories);

  int get weeklyTotalMinutes =>
      weeklySummaries.fold<int>(0, (sum, day) => sum + day.workoutMinutes);

  double get weeklyTotalDistance =>
      weeklySummaries.fold<double>(0.0, (sum, day) => sum + day.distance);

  int get weeklyAvgSteps => (weeklyTotalSteps / 7).round();

  double get weeklyAvgCalories =>
      double.parse((weeklyTotalCalories / 7).toStringAsFixed(1));

  // Total Lifetime Stats
  int get totalLifetimeWorkouts => _activities.length;
  double get totalLifetimeCalories =>
      _activities.fold<double>(0.0, (sum, a) => sum + a.calories);
  int get totalLifetimeSteps =>
      _activities.fold<int>(0, (sum, a) => sum + (a.steps ?? 0));

  Future<void> loadActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _dbHelper.getAllActivities();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load activities: $e';
      notifyListeners();
    }
  }

  Future<bool> addActivity(Activity activity) async {
    try {
      await _dbHelper.insertActivity(activity);
      await loadActivities();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add activity: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateActivity(Activity activity) async {
    try {
      await _dbHelper.updateActivity(activity);
      await loadActivities();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update activity: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteActivity(int id) async {
    try {
      await _dbHelper.deleteActivity(id);
      await loadActivities();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete activity: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> seedSampleData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbHelper.seedSampleActivities();
      await loadActivities();
    } catch (e) {
      _errorMessage = 'Failed to seed sample data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbHelper.clearAllActivities();
      await loadActivities();
    } catch (e) {
      _errorMessage = 'Failed to clear data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}

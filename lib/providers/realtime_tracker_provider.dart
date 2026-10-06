import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/fitness_service.dart';
import '../services/realtime_tracker_service.dart';
import 'activity_provider.dart';

class RealtimeTrackerProvider with ChangeNotifier {
  final RealtimeTrackerService _service = RealtimeTrackerService.instance;

  bool _isSessionActive = false;
  bool _isSessionPaused = false;
  String _sessionType = 'Walking';
  int _sessionDurationSeconds = 0;
  int _sessionSteps = 0;
  double _sessionDistanceMeters = 0.0;
  double _sessionCalories = 0.0;
  double _sessionSpeedKmh = 0.0;
  DateTime? _sessionStartTime;
  Timer? _sessionTimer;

  int _sessionStartLiveSteps = 0;
  Position? _lastSessionPosition;
  StreamSubscription<Position>? _sessionPositionSub;

  RealtimeTrackerProvider({bool autoInit = true}) {
    if (autoInit) {
      _init();
    }
  }

  void _init() {
    _service.onMetricsUpdated = () {
      notifyListeners();
    };
    _service.initialize();
  }

  int get todayLiveSteps => _service.todayLiveSteps;
  double get todayLiveDistanceKm => _service.todayLiveDistanceKm;
  double get todayLiveCalories => _service.todayLiveCalories;
  double get currentSpeedKmh => _isSessionActive ? _sessionSpeedKmh : _service.currentSpeedKmh;
  String get pedestrianStatus => _service.pedestrianStatus;
  bool get hasPermissions => _service.hasActivityPermission && _service.hasLocationPermission;
  bool get hasActivityPermission => _service.hasActivityPermission;
  bool get hasLocationPermission => _service.hasLocationPermission;
  bool get isStepSensorActive => _service.isStepCounterAvailable;
  bool get isGpsActive => _service.isGpsAvailable;

  bool get isSessionActive => _isSessionActive;
  bool get isSessionPaused => _isSessionPaused;
  String get sessionType => _sessionType;
  int get sessionDurationSeconds => _sessionDurationSeconds;
  int get sessionSteps => _sessionSteps;
  double get sessionDistanceKm => _sessionDistanceMeters / 1000.0;
  double get sessionCalories => _sessionCalories;
  double get sessionSpeedKmh => _sessionSpeedKmh;
  DateTime? get sessionStartTime => _sessionStartTime;

  String get formattedSessionDuration {
    final hours = _sessionDurationSeconds ~/ 3600;
    final minutes = (_sessionDurationSeconds % 3600) ~/ 60;
    final seconds = _sessionDurationSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<bool> requestPermissions() async {
    final granted = await _service.requestPermissions();
    notifyListeners();
    return granted;
  }

  Future<void> startSession(String activityType) async {
    if (!hasPermissions) {
      await requestPermissions();
    }

    _isSessionActive = true;
    _isSessionPaused = false;
    _sessionType = activityType;
    _sessionDurationSeconds = 0;
    _sessionSteps = 0;
    _sessionDistanceMeters = 0.0;
    _sessionCalories = 0.0;
    _sessionSpeedKmh = 0.0;
    _sessionStartTime = DateTime.now();
    _sessionStartLiveSteps = _service.todayLiveSteps;
    _lastSessionPosition = null;

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isSessionPaused) {
        _sessionDurationSeconds++;

        final stepsDiff = _service.todayLiveSteps - _sessionStartLiveSteps;
        if (stepsDiff > 0) {
          _sessionSteps = stepsDiff;
        } else if (_sessionDistanceMeters > 0) {
          _sessionSteps = (_sessionDistanceMeters / 0.76).round();
        }

        _calculateSessionCalories();
        notifyListeners();
      }
    });

    _sessionPositionSub?.cancel();
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      );

      _sessionPositionSub = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        if (!_isSessionPaused && _isSessionActive) {
          final speed = position.speed;
          _sessionSpeedKmh = speed > 0 ? (speed * 3.6) : 0.0;

          if (_lastSessionPosition != null) {
            final delta = Geolocator.distanceBetween(
              _lastSessionPosition!.latitude,
              _lastSessionPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            if (delta >= 1.5 && delta < 200.0) {
              _sessionDistanceMeters += delta;
              _service.addLiveDistance(delta);

              if (!_service.isStepCounterAvailable) {
                final addedSteps = (delta / 0.76).round();
                _sessionSteps += addedSteps;
                _service.addLiveSteps(addedSteps);
              }
            }
          }

          _lastSessionPosition = position;
          _calculateSessionCalories();
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Failed to start session GPS stream: $e');
    }

    notifyListeners();
  }

  void pauseSession() {
    _isSessionPaused = true;
    _sessionSpeedKmh = 0.0;
    notifyListeners();
  }

  void resumeSession() {
    _isSessionPaused = false;
    notifyListeners();
  }

  void _calculateSessionCalories() {
    final distanceKm = sessionDistanceKm;
    final durationMinutes = _sessionDurationSeconds / 60.0;

    double calBurn = 0.0;
    switch (_sessionType) {
      case 'Running':
        calBurn = (distanceKm * 65.0) + (durationMinutes * 4.0);
        break;
      case 'Cycling':
        calBurn = (distanceKm * 32.0) + (durationMinutes * 3.5);
        break;
      case 'Walking':
      case 'Travel':
      default:
        calBurn = (distanceKm * 48.0) + (_sessionSteps * 0.038);
        break;
    }

    if (calBurn <= 0.0 && durationMinutes > 0.5) {
      calBurn = durationMinutes * 3.0;
    }

    _sessionCalories = double.parse(calBurn.toStringAsFixed(1));
  }

  Future<bool> finishSession(ActivityProvider activityProvider) async {
    _sessionTimer?.cancel();
    _sessionPositionSub?.cancel();

    final now = DateTime.now();
    final durationMinutes = math.max(1, (_sessionDurationSeconds / 60).round());
    final distanceKm = sessionDistanceKm;
    final steps = _sessionSteps;
    final calories = _sessionCalories > 0
        ? _sessionCalories
        : FitnessService.estimateCalories(_sessionType, durationMinutes);

    final timeStr = DateFormat('hh:mm a').format(_sessionStartTime ?? now);
    final dateStr = FitnessService.formatDateKey(_sessionStartTime ?? now);

    final activity = Activity(
      exerciseType: _sessionType,
      duration: durationMinutes,
      calories: calories,
      distance: distanceKm > 0 ? double.parse(distanceKm.toStringAsFixed(2)) : null,
      steps: steps > 0 ? steps : null,
      date: dateStr,
      time: timeStr,
      notes: 'Real-time session: $formattedSessionDuration tracked with GPS & sensors',
    );

    final success = await activityProvider.addActivity(activity);

    _isSessionActive = false;
    _isSessionPaused = false;
    _sessionDurationSeconds = 0;
    _sessionSteps = 0;
    _sessionDistanceMeters = 0.0;
    _sessionCalories = 0.0;
    _sessionSpeedKmh = 0.0;
    _sessionStartTime = null;

    notifyListeners();
    return success;
  }

  void discardSession() {
    _sessionTimer?.cancel();
    _sessionPositionSub?.cancel();
    _isSessionActive = false;
    _isSessionPaused = false;
    _sessionDurationSeconds = 0;
    _sessionSteps = 0;
    _sessionDistanceMeters = 0.0;
    _sessionCalories = 0.0;
    _sessionSpeedKmh = 0.0;
    _sessionStartTime = null;
    notifyListeners();
  }

  Future<void> resetTodayLiveStats() async {
    await _service.resetTodayMetrics();
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _sessionPositionSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}

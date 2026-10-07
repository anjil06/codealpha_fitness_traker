import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fitness_service.dart';

class RealtimeTrackerService {
  static final RealtimeTrackerService _instance = RealtimeTrackerService._internal();
  static RealtimeTrackerService get instance => _instance;

  RealtimeTrackerService._internal();

  // Streams & Subscriptions
  StreamSubscription<StepCount>? _stepCountSub;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSub;
  StreamSubscription<Position>? _positionSub;

  // Status flags
  bool _isStepCounterAvailable = false;
  bool _isGpsAvailable = false;
  bool _hasActivityPermission = false;
  bool _hasLocationPermission = false;
  bool _isPermanentlyDenied = false;
  bool _isLocationServiceEnabled = true;

  // Daily Live Metrics
  int _todayLiveSteps = 0;
  double _todayLiveDistanceMeters = 0.0;
  String _pedestrianStatus = 'stopped';

  // Sensor Baselines
  int _dayStartRawSteps = 0;
  int _lastRawSteps = 0;
  String _lastRecordedDate = '';

  // GPS Tracking Variables
  Position? _lastPosition;
  double _currentSpeedKmh = 0.0;

  // Callbacks
  VoidCallback? onMetricsUpdated;

  // Getters
  bool get isStepCounterAvailable => _isStepCounterAvailable;
  bool get isGpsAvailable => _isGpsAvailable;
  bool get hasActivityPermission => _hasActivityPermission;
  bool get hasLocationPermission => _hasLocationPermission;
  bool get isPermanentlyDenied => _isPermanentlyDenied;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  int get todayLiveSteps => _todayLiveSteps;
  double get todayLiveDistanceKm => _todayLiveDistanceMeters / 1000.0;
  double get currentSpeedKmh => _currentSpeedKmh;
  String get pedestrianStatus => _pedestrianStatus;

  double get todayLiveCalories {
    final stepCals = _todayLiveSteps * 0.04;
    final distCals = todayLiveDistanceKm * 60.0;
    return (stepCals > distCals ? stepCals : distCals);
  }

  Future<void> initialize() async {
    await _loadSavedDailyState();
    await checkPermissions();
    if (_hasActivityPermission) {
      _startStepCounter();
    }
    if (_hasLocationPermission) {
      await _checkAndStartGps();
    }
  }

  Future<void> checkPermissions() async {
    try {
      final activityStatus = await Permission.activityRecognition.status;
      _hasActivityPermission = activityStatus.isGranted;

      final locationStatus = await Permission.locationWhenInUse.status;
      _hasLocationPermission = locationStatus.isGranted;

      _isPermanentlyDenied = activityStatus.isPermanentlyDenied || locationStatus.isPermanentlyDenied;
      _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      onMetricsUpdated?.call();
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      // If permanently denied by OS, direct the user to device Settings
      if (_isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      final activityResult = await Permission.activityRecognition.request();
      _hasActivityPermission = activityResult.isGranted;

      final locationResult = await Permission.locationWhenInUse.request();
      _hasLocationPermission = locationResult.isGranted;

      _isPermanentlyDenied = activityResult.isPermanentlyDenied || locationResult.isPermanentlyDenied;
      _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!_isLocationServiceEnabled && _hasLocationPermission) {
        await Geolocator.openLocationSettings();
      }

      if (_hasActivityPermission) {
        _startStepCounter();
      }
      if (_hasLocationPermission) {
        await _checkAndStartGps();
      }

      onMetricsUpdated?.call();
      return _hasActivityPermission && _hasLocationPermission;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  void _startStepCounter() {
    _stepCountSub?.cancel();
    _pedestrianStatusSub?.cancel();

    try {
      _stepCountSub = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (error) {
          debugPrint('Pedometer step count stream error: $error');
          _isStepCounterAvailable = false;
          onMetricsUpdated?.call();
        },
        cancelOnError: false,
      );

      _pedestrianStatusSub = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatus,
        onError: (error) {
          debugPrint('Pedometer pedestrian status stream error: $error');
        },
        cancelOnError: false,
      );

      _isStepCounterAvailable = true;
    } catch (e) {
      debugPrint('Failed to start pedometer stream: $e');
      _isStepCounterAvailable = false;
    }
  }

  void _onStepCount(StepCount event) async {
    final todayKey = FitnessService.formatDateKey(DateTime.now());
    final currentRawSteps = event.steps;

    if (_lastRecordedDate != todayKey) {
      _lastRecordedDate = todayKey;
      _dayStartRawSteps = currentRawSteps;
      _lastRawSteps = currentRawSteps;
      _todayLiveSteps = 0;
      _todayLiveDistanceMeters = 0.0;
    } else {
      if (currentRawSteps < _lastRawSteps) {
        _dayStartRawSteps = currentRawSteps;
        _lastRawSteps = currentRawSteps;
      } else {
        final diff = currentRawSteps - _dayStartRawSteps;
        _todayLiveSteps = math.max(0, diff);
        _lastRawSteps = currentRawSteps;
      }
    }

    _isStepCounterAvailable = true;
    await _persistDailyState();
    onMetricsUpdated?.call();
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    _pedestrianStatus = event.status;
    onMetricsUpdated?.call();
  }

  Future<void> _checkAndStartGps() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isGpsAvailable = false;
        return;
      }

      _positionSub?.cancel();

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      );

      _positionSub = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _onLocationUpdate,
        onError: (e) {
          debugPrint('Geolocator stream error: $e');
          _isGpsAvailable = false;
          onMetricsUpdated?.call();
        },
        cancelOnError: false,
      );

      _isGpsAvailable = true;
    } catch (e) {
      debugPrint('Failed to start GPS stream: $e');
      _isGpsAvailable = false;
    }
  }

  void _onLocationUpdate(Position position) async {
    _isGpsAvailable = true;

    final speed = position.speed;
    _currentSpeedKmh = speed > 0 ? (speed * 3.6) : 0.0;

    if (_lastPosition != null) {
      final distanceInMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distanceInMeters >= 2.0 && distanceInMeters < 250.0) {
        _todayLiveDistanceMeters += distanceInMeters;

        if (!_isStepCounterAvailable && _todayLiveSteps == 0) {
          _todayLiveSteps = (_todayLiveDistanceMeters / 0.76).round();
        }

        await _persistDailyState();
      }
    }

    _lastPosition = position;
    onMetricsUpdated?.call();
  }

  void addLiveDistance(double meters) {
    _todayLiveDistanceMeters += meters;
    _persistDailyState();
    onMetricsUpdated?.call();
  }

  void addLiveSteps(int steps) {
    _todayLiveSteps += steps;
    _persistDailyState();
    onMetricsUpdated?.call();
  }

  Future<void> resetTodayMetrics() async {
    _todayLiveSteps = 0;
    _todayLiveDistanceMeters = 0.0;
    _currentSpeedKmh = 0.0;
    await _persistDailyState();
    onMetricsUpdated?.call();
  }

  Future<void> _loadSavedDailyState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = FitnessService.formatDateKey(DateTime.now());
      final savedDate = prefs.getString('live_saved_date') ?? '';

      if (savedDate == todayKey) {
        _todayLiveSteps = prefs.getInt('live_today_steps') ?? 0;
        _todayLiveDistanceMeters = prefs.getDouble('live_today_distance_m') ?? 0.0;
        _dayStartRawSteps = prefs.getInt('live_day_start_raw') ?? 0;
        _lastRawSteps = prefs.getInt('live_last_raw') ?? 0;
        _lastRecordedDate = savedDate;
      } else {
        _lastRecordedDate = todayKey;
        _todayLiveSteps = 0;
        _todayLiveDistanceMeters = 0.0;
        _dayStartRawSteps = 0;
        _lastRawSteps = 0;
        await _persistDailyState();
      }
    } catch (e) {
      debugPrint('Error loading saved daily state: $e');
    }
  }

  Future<void> _persistDailyState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = FitnessService.formatDateKey(DateTime.now());
      await prefs.setString('live_saved_date', todayKey);
      await prefs.setInt('live_today_steps', _todayLiveSteps);
      await prefs.setDouble('live_today_distance_m', _todayLiveDistanceMeters);
      await prefs.setInt('live_day_start_raw', _dayStartRawSteps);
      await prefs.setInt('live_last_raw', _lastRawSteps);
    } catch (e) {
      debugPrint('Error persisting daily state: $e');
    }
  }

  void dispose() {
    _stepCountSub?.cancel();
    _pedestrianStatusSub?.cancel();
    _positionSub?.cancel();
  }
}

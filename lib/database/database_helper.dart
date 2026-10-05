import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/activity.dart';
import '../models/fitness_goal.dart';

class DatabaseHelper {
  static const String _databaseName = 'fitness_tracker.db';
  static const int _databaseVersion = 1;

  static const String tableActivities = 'activities';
  static const String tableGoals = 'goals';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $tableActivities ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'exerciseType TEXT NOT NULL, '
      'duration INTEGER NOT NULL, '
      'calories REAL NOT NULL, '
      'distance REAL, '
      'steps INTEGER, '
      'date TEXT NOT NULL, '
      'time TEXT, '
      'notes TEXT'
      ')',
    );

    await db.execute(
      'CREATE TABLE $tableGoals ('
      'id INTEGER PRIMARY KEY, '
      'steps INTEGER NOT NULL, '
      'calories REAL NOT NULL, '
      'workoutMinutes INTEGER NOT NULL, '
      'distance REAL NOT NULL'
      ')',
    );

    await db.insert(
      tableGoals,
      FitnessGoal().toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    return await db.insert(
      tableActivities,
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await database;
    return await db.update(
      tableActivities,
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    return await db.delete(
      tableActivities,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Activity>> getAllActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableActivities,
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((map) => Activity.fromMap(map)).toList();
  }

  Future<List<Activity>> getActivitiesByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableActivities,
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
    return maps.map((map) => Activity.fromMap(map)).toList();
  }

  Future<List<Activity>> getActivitiesForDateRange(String startDate, String endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableActivities,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC, id ASC',
    );
    return maps.map((map) => Activity.fromMap(map)).toList();
  }

  Future<FitnessGoal> getGoal() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableGoals,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return FitnessGoal.fromMap(maps.first);
    } else {
      final defaultGoal = FitnessGoal();
      await db.insert(tableGoals, defaultGoal.toMap());
      return defaultGoal;
    }
  }

  Future<int> updateGoal(FitnessGoal goal) async {
    final db = await database;
    return await db.insert(
      tableGoals,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAllActivities() async {
    final db = await database;
    await db.delete(tableActivities);
  }

  Future<void> seedSampleActivities() async {
    final now = DateTime.now();
    final today = _formatDate(now);
    final yesterday = _formatDate(now.subtract(const Duration(days: 1)));
    final day2 = _formatDate(now.subtract(const Duration(days: 2)));
    final day3 = _formatDate(now.subtract(const Duration(days: 3)));
    final day4 = _formatDate(now.subtract(const Duration(days: 4)));
    final day5 = _formatDate(now.subtract(const Duration(days: 5)));
    final day6 = _formatDate(now.subtract(const Duration(days: 6)));

    final samples = [
      Activity(
        exerciseType: 'Running',
        duration: 35,
        calories: 320,
        distance: 4.5,
        steps: 5120,
        date: today,
        time: '07:15 AM',
        notes: 'Morning park run, felt energetic and smooth pacing!',
      ),
      Activity(
        exerciseType: 'Walking',
        duration: 20,
        calories: 95,
        distance: 1.6,
        steps: 2200,
        date: today,
        time: '01:30 PM',
        notes: 'Post-lunch brisk walk around campus.',
      ),
      Activity(
        exerciseType: 'Gym',
        duration: 45,
        calories: 310,
        distance: null,
        steps: 800,
        date: yesterday,
        time: '06:00 PM',
        notes: 'Chest and triceps workout with progressive overload.',
      ),
      Activity(
        exerciseType: 'Cycling',
        duration: 50,
        calories: 420,
        distance: 12.4,
        steps: null,
        date: day2,
        time: '05:45 PM',
        notes: 'Evening cycle route by the lake road.',
      ),
      Activity(
        exerciseType: 'Yoga',
        duration: 30,
        calories: 110,
        distance: null,
        steps: null,
        date: day3,
        time: '08:00 AM',
        notes: 'Deep stretching and flexibility session.',
      ),
      Activity(
        exerciseType: 'HIIT',
        duration: 25,
        calories: 280,
        distance: null,
        steps: 1900,
        date: day4,
        time: '06:30 PM',
        notes: 'High-intensity interval training tabata routine.',
      ),
      Activity(
        exerciseType: 'Walking',
        duration: 40,
        calories: 180,
        distance: 3.2,
        steps: 4300,
        date: day5,
        time: '07:00 AM',
        notes: 'Morning trail walking.',
      ),
      Activity(
        exerciseType: 'Swimming',
        duration: 45,
        calories: 410,
        distance: 1.2,
        steps: null,
        date: day6,
        time: '04:00 PM',
        notes: 'Freestyle and breaststroke laps in community pool.',
      ),
    ];

    for (final act in samples) {
      await insertActivity(act);
    }
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

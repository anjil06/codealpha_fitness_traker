import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fittrack/models/activity.dart';
import 'package:fittrack/models/fitness_goal.dart';
import 'package:fittrack/providers/activity_provider.dart';
import 'package:fittrack/providers/realtime_tracker_provider.dart';
import 'package:fittrack/screens/live_workout_screen.dart';
import 'package:fittrack/services/fitness_service.dart';
import 'package:fittrack/widgets/summary_card.dart';
import 'package:fittrack/widgets/progress_card.dart';

void main() {
  group('Fitness Models & Services Tests', () {
    test('Activity toMap and fromMap works correctly', () {
      final activity = Activity(
        id: 1,
        exerciseType: 'Running',
        duration: 30,
        calories: 250.0,
        distance: 4.2,
        steps: 4500,
        date: '2026-10-05',
        time: '06:30 PM',
        notes: 'Great morning run',
      );

      final map = activity.toMap();
      expect(map['exerciseType'], 'Running');
      expect(map['duration'], 30);
      expect(map['calories'], 250.0);
      expect(map['distance'], 4.2);
      expect(map['steps'], 4500);
      expect(map['date'], '2026-10-05');
      expect(map['time'], '06:30 PM');
      expect(map['notes'], 'Great morning run');

      final reconstructed = Activity.fromMap(map);
      expect(reconstructed.id, 1);
      expect(reconstructed.exerciseType, 'Running');
      expect(reconstructed.duration, 30);
      expect(reconstructed.calories, 250.0);
      expect(reconstructed.distance, 4.2);
      expect(reconstructed.steps, 4500);
    });

    test('FitnessGoal toMap, fromMap and copyWith works correctly', () {
      final goal = FitnessGoal(
        id: 1,
        steps: 10000,
        calories: 700.0,
        workoutMinutes: 60,
        distance: 5.0,
      );

      final map = goal.toMap();
      final reconstructed = FitnessGoal.fromMap(map);
      expect(reconstructed.steps, 10000);
      expect(reconstructed.calories, 700.0);
      expect(reconstructed.workoutMinutes, 60);
      expect(reconstructed.distance, 5.0);

      final updated = reconstructed.copyWith(steps: 12000, calories: 850.0);
      expect(updated.steps, 12000);
      expect(updated.calories, 850.0);
      expect(updated.workoutMinutes, 60);
    });

    test('FitnessService progress and percentage calculations', () {
      expect(FitnessService.calculateProgress(5000, 10000), 0.5);
      expect(FitnessService.calculatePercentage(5000, 10000), 50);

      expect(FitnessService.calculateProgress(15000, 10000), 1.0);
      expect(FitnessService.calculatePercentage(15000, 10000), 100);

      expect(FitnessService.calculateProgress(100, 0), 0.0);
    });

    test('FitnessService calorie estimation', () {
      final runningCalories = FitnessService.estimateCalories('Running', 30);
      expect(runningCalories, 300.0);

      final walkingCalories = FitnessService.estimateCalories('Walking', 20);
      expect(walkingCalories, 90.0);
    });
  });

  group('Widget Rendering Tests', () {
    testWidgets('SummaryCard renders correct metrics and labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SummaryCard(
              title: 'Steps',
              value: '6,842',
              goalText: '/ 10,000',
              progress: 0.68,
              icon: Icons.directions_walk_rounded,
              accentColor: Colors.green,
              iconBgColor: Color(0xFFE8F5E9),
            ),
          ),
        ),
      );

      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('6,842'), findsOneWidget);
      expect(find.text('/ 10,000'), findsOneWidget);
      expect(find.text('68%'), findsOneWidget);
    });

    testWidgets('ProgressCard renders all progress items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProgressCard(
                steps: 6842,
                stepGoal: 10000,
                calories: 524,
                calorieGoal: 700,
                workoutMinutes: 45,
                workoutGoal: 60,
                distance: 4.8,
                distanceGoal: 5.0,
              ),
            ),
          ),
        ),
      );

      expect(find.text("Today's Progress"), findsOneWidget);
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
    });

    testWidgets('LiveWorkoutScreen renders initial UI components', (tester) async {
      final activityProvider = ActivityProvider();
      final trackerProvider = RealtimeTrackerProvider(autoInit: false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: activityProvider),
            ChangeNotifierProvider.value(value: trackerProvider),
          ],
          child: const MaterialApp(
            home: LiveWorkoutScreen(),
          ),
        ),
      );

      expect(find.text('Live Activity Tracker'), findsOneWidget);
      expect(find.text('Select Activity Type'), findsOneWidget);
      expect(find.text('Walking'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Start Tracking Walking'), findsOneWidget);
      expect(find.text('DISTANCE TRAVELED'), findsOneWidget);
    });
  });
}


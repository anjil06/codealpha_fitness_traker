import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/realtime_tracker_provider.dart';
import '../services/fitness_service.dart';
import '../utils/app_theme.dart';
import '../widgets/activity_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_card.dart';
import '../widgets/realtime_tracker_banner.dart';
import '../widgets/summary_card.dart';
import '../widgets/weekly_chart.dart';
import 'add_activity_screen.dart';
import 'live_workout_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHistory;
  final VoidCallback? onNavigateToSettings;

  const DashboardScreen({
    super.key,
    this.onNavigateToHistory,
    this.onNavigateToSettings,
  });

  @override
  Widget build(BuildContext context) {
    final activityProv = Provider.of<ActivityProvider>(context);
    final goalProv = Provider.of<GoalProvider>(context);
    final trackerProv = Provider.of<RealtimeTrackerProvider>(context);
    final goal = goalProv.goal;
    final theme = Theme.of(context);

    final now = DateTime.now();
    final greeting = FitnessService.getGreeting();
    final dateStr = FitnessService.formatHeaderDate(now);

    // Combined metrics: SQLite logged workouts + real-time hardware sensor tracking
    final displaySteps = activityProv.todaySteps + trackerProv.todayLiveSteps;
    final displayCalories = activityProv.todayCalories + trackerProv.todayLiveCalories;
    final displayDistance = activityProv.todayDistance + trackerProv.todayLiveDistanceKm;
    final displayDuration = activityProv.todayDuration + (trackerProv.sessionDurationSeconds ~/ 60);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              activityProv.loadActivities(),
              goalProv.loadGoal(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Device-based, no user login)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting 👋',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phone Activity Tracker · $dateStr',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onNavigateToSettings,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smartphone_rounded,
                          color: AppTheme.primaryDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Real-time Live Sensor & Trip Tracker Banner
                const RealtimeTrackerBanner(),

                // Daily Summary Cards (Combined Real-Time + Stored Data)
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Steps',
                        value: displaySteps.toString(),
                        goalText: '/ ${goal.steps}',
                        progress: FitnessService.calculateProgress(
                          displaySteps,
                          goal.steps,
                        ),
                        icon: Icons.directions_walk_rounded,
                        accentColor: AppTheme.primaryColor,
                        iconBgColor: AppTheme.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SummaryCard(
                        title: 'Calories',
                        value: '${displayCalories.toInt()} kcal',
                        goalText: '/ ${goal.calories.toInt()} kcal',
                        progress: FitnessService.calculateProgress(
                          displayCalories,
                          goal.calories,
                        ),
                        icon: Icons.local_fire_department_rounded,
                        accentColor: AppTheme.accentOrange,
                        iconBgColor: const Color(0xFFFFF3E0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Workout',
                        value: '$displayDuration min',
                        goalText: '/ ${goal.workoutMinutes} min',
                        progress: FitnessService.calculateProgress(
                          displayDuration,
                          goal.workoutMinutes,
                        ),
                        icon: Icons.timer_rounded,
                        accentColor: AppTheme.secondaryColor,
                        iconBgColor: AppTheme.secondaryLight,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SummaryCard(
                        title: 'Distance',
                        value: '${displayDistance.toStringAsFixed(1)} km',
                        goalText: '/ ${goal.distance.toStringAsFixed(1)} km',
                        progress: FitnessService.calculateProgress(
                          displayDistance,
                          goal.distance,
                        ),
                        icon: Icons.place_rounded,
                        accentColor: AppTheme.accentPurple,
                        iconBgColor: const Color(0xFFF3E5F5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Card
                ProgressCard(
                  steps: displaySteps,
                  stepGoal: goal.steps,
                  calories: displayCalories,
                  calorieGoal: goal.calories,
                  workoutMinutes: displayDuration,
                  workoutGoal: goal.workoutMinutes,
                  distance: displayDistance,
                  distanceGoal: goal.distance,
                ),

                const SizedBox(height: 24),

                // Weekly Chart
                WeeklyChart(
                  weeklySummaries: activityProv.weeklySummaries,
                ),

                const SizedBox(height: 28),

                // Recent Activities Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activities',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (activityProv.activities.isNotEmpty)
                      TextButton(
                        onPressed: onNavigateToHistory,
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recent Activities List
                if (activityProv.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (activityProv.activities.isEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: EmptyState(
                      title: 'No activities yet',
                      message: 'Track a trip or add your first workout\nto see progress on this device.',
                      onActionPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddActivityScreen(),
                          ),
                        );
                      },
                      onSecondaryActionPressed: () async {
                        await activityProv.seedSampleData();
                      },
                      secondaryActionLabel: 'Load Sample Activities',
                    ),
                  )
                else
                  ...activityProv.recentActivities.map((act) {
                    return ActivityCard(
                      activity: act,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddActivityScreen(
                              activityToEdit: act,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        if (act.id != null) {
                          activityProv.deleteActivity(act.id!);
                        }
                      },
                    );
                  }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'liveTrackerFab',
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            elevation: 3,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LiveWorkoutScreen(),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 24),
            label: const Text(
              'Track Trip',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'addActivityFab',
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 3,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddActivityScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 24),
            label: const Text(
              'Add Activity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

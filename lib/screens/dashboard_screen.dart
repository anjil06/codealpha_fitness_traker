import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../providers/goal_provider.dart';
import '../services/fitness_service.dart';
import '../utils/app_theme.dart';
import '../widgets/activity_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/weekly_chart.dart';
import 'add_activity_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHistory;
  final VoidCallback? onNavigateToProfile;

  const DashboardScreen({
    super.key,
    this.onNavigateToHistory,
    this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final activityProv = Provider.of<ActivityProvider>(context);
    final goalProv = Provider.of<GoalProvider>(context);
    final goal = goalProv.goal;
    final userName = goalProv.userName;
    final theme = Theme.of(context);

    final now = DateTime.now();
    final greeting = FitnessService.getGreeting();
    final dateStr = FitnessService.formatHeaderDate(now);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              activityProv.loadActivities(),
              goalProv.loadGoalAndUser(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, $userName 👋',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onNavigateToProfile,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primaryLight,
                          child: Icon(
                            Icons.person_rounded,
                            color: AppTheme.primaryDark,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Steps',
                        value: activityProv.todaySteps.toString(),
                        goalText: '/ ${goal.steps}',
                        progress: FitnessService.calculateProgress(
                          activityProv.todaySteps,
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
                        value: '${activityProv.todayCalories.toInt()} kcal',
                        goalText: '/ ${goal.calories.toInt()} kcal',
                        progress: FitnessService.calculateProgress(
                          activityProv.todayCalories,
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
                        value: '${activityProv.todayDuration} min',
                        goalText: '/ ${goal.workoutMinutes} min',
                        progress: FitnessService.calculateProgress(
                          activityProv.todayDuration,
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
                        value: '${activityProv.todayDistance.toStringAsFixed(1)} km',
                        goalText: '/ ${goal.distance.toStringAsFixed(1)} km',
                        progress: FitnessService.calculateProgress(
                          activityProv.todayDistance,
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

                ProgressCard(
                  steps: activityProv.todaySteps,
                  stepGoal: goal.steps,
                  calories: activityProv.todayCalories,
                  calorieGoal: goal.calories,
                  workoutMinutes: activityProv.todayDuration,
                  workoutGoal: goal.workoutMinutes,
                  distance: activityProv.todayDistance,
                  distanceGoal: goal.distance,
                ),

                const SizedBox(height: 24),

                WeeklyChart(
                  weeklySummaries: activityProv.weeklySummaries,
                ),

                const SizedBox(height: 28),

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
                      message: 'Start tracking your fitness journey\nby adding your first activity.',
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
    );
  }
}

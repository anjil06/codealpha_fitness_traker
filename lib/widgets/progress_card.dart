import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ProgressCard extends StatelessWidget {
  final int steps;
  final int stepGoal;
  final double calories;
  final double calorieGoal;
  final int workoutMinutes;
  final int workoutGoal;
  final double distance;
  final double distanceGoal;

  const ProgressCard({
    super.key,
    required this.steps,
    required this.stepGoal,
    required this.calories,
    required this.calorieGoal,
    required this.workoutMinutes,
    required this.workoutGoal,
    required this.distance,
    required this.distanceGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Progress",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 14, color: AppTheme.primaryDark),
                    SizedBox(width: 4),
                    Text(
                      'Daily Goals',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressItem(
            context: context,
            label: 'Steps',
            current: steps.toDouble(),
            goal: stepGoal.toDouble(),
            unit: 'steps',
            color: AppTheme.primaryColor,
            icon: Icons.directions_walk_rounded,
          ),
          const SizedBox(height: 16),
          _buildProgressItem(
            context: context,
            label: 'Calories',
            current: calories,
            goal: calorieGoal,
            unit: 'kcal',
            color: AppTheme.accentOrange,
            icon: Icons.local_fire_department_rounded,
          ),
          const SizedBox(height: 16),
          _buildProgressItem(
            context: context,
            label: 'Workout',
            current: workoutMinutes.toDouble(),
            goal: workoutGoal.toDouble(),
            unit: 'min',
            color: AppTheme.secondaryColor,
            icon: Icons.timer_rounded,
          ),
          const SizedBox(height: 16),
          _buildProgressItem(
            context: context,
            label: 'Distance',
            current: distance,
            goal: distanceGoal,
            unit: 'km',
            color: AppTheme.accentPurple,
            icon: Icons.place_rounded,
            decimal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required BuildContext context,
    required String label,
    required double current,
    required double goal,
    required String unit,
    required Color color,
    required IconData icon,
    bool decimal = false,
  }) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    final currentDisplay = decimal ? current.toStringAsFixed(1) : current.toInt().toString();
    final goalDisplay = decimal ? goal.toStringAsFixed(1) : goal.toInt().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '$currentDisplay / $goalDisplay $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withAlpha(35),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

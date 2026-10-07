import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/realtime_tracker_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../services/app_update_service.dart';
import 'goals_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _confirmClearData(BuildContext context, ActivityProvider activityProv, RealtimeTrackerProvider trackerProv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Device Activities?'),
        content: const Text(
          'This will permanently delete all recorded activities and sensor history from this phone. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await activityProv.clearAllData();
              await trackerProv.resetTodayLiveStats();
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All activities cleared from this device.'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalProv = Provider.of<GoalProvider>(context);
    final activityProv = Provider.of<ActivityProvider>(context);
    final trackerProv = Provider.of<RealtimeTrackerProvider>(context);
    final goal = goalProv.goal;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Device & Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Device Information Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.phone_android_rounded,
                          size: 36,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device Tracker',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Activities belong to this phone',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppTheme.dividerColor, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLifetimeStat(
                        'Workouts',
                        activityProv.totalLifetimeWorkouts.toString(),
                        AppTheme.primaryColor,
                      ),
                      Container(height: 30, width: 1, color: AppTheme.dividerColor),
                      _buildLifetimeStat(
                        'Total kcal',
                        activityProv.totalLifetimeCalories.toInt().toString(),
                        AppTheme.accentOrange,
                      ),
                      Container(height: 30, width: 1, color: AppTheme.dividerColor),
                      _buildLifetimeStat(
                        'Total Steps',
                        (activityProv.totalLifetimeSteps + trackerProv.todayLiveSteps).toString(),
                        AppTheme.secondaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hardware Sensors & Diagnostics Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Sensors & GPS',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSensorRow(
                    title: 'Hardware Step Counter',
                    status: trackerProv.isStepSensorActive ? 'Active' : (trackerProv.hasActivityPermission ? 'Listening' : 'Needs Permission'),
                    isActive: trackerProv.isStepSensorActive || trackerProv.hasActivityPermission,
                    icon: Icons.directions_walk_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildSensorRow(
                    title: 'GPS Location Tracking',
                    status: trackerProv.isGpsActive ? 'Active' : (trackerProv.hasLocationPermission ? 'Ready' : 'Needs Permission'),
                    isActive: trackerProv.isGpsActive || trackerProv.hasLocationPermission,
                    icon: Icons.gps_fixed_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildSensorRow(
                    title: 'Local SQLite Database',
                    status: 'Connected',
                    isActive: true,
                    icon: Icons.storage_rounded,
                  ),
                  if (!trackerProv.hasPermissions || !trackerProv.isLocationServiceEnabled) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (!trackerProv.isLocationServiceEnabled && trackerProv.hasLocationPermission) {
                            trackerProv.openLocationSettings();
                          } else if (trackerProv.isPermanentlyDenied) {
                            trackerProv.openSettings();
                          } else {
                            trackerProv.requestPermissions();
                          }
                        },
                        icon: Icon(
                          trackerProv.isPermanentlyDenied
                              ? Icons.settings_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 20,
                        ),
                        label: Text(
                          !trackerProv.isLocationServiceEnabled && trackerProv.hasLocationPermission
                              ? 'Turn On Location (GPS)'
                              : (trackerProv.isPermanentlyDenied
                                  ? 'Open Settings to Allow Permissions'
                                  : 'Grant Sensor & GPS Permissions'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Daily Goals for Device
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Device Daily Targets',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        label: const Text('Edit Targets'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const GoalsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGoalRow('Steps', '${goal.steps} steps', Icons.directions_walk_rounded, AppTheme.primaryColor),
                  const SizedBox(height: 10),
                  _buildGoalRow('Calories', '${goal.calories.toInt()} kcal', Icons.local_fire_department_rounded, AppTheme.accentOrange),
                  const SizedBox(height: 10),
                  _buildGoalRow('Workout', '${goal.workoutMinutes} min', Icons.timer_rounded, AppTheme.secondaryColor),
                  const SizedBox(height: 10),
                  _buildGoalRow('Distance', '${goal.distance.toStringAsFixed(1)} km', Icons.place_rounded, AppTheme.accentPurple),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Data Management
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    title: const Text(
                      'Load Sample Activities',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Seed 7 days of realistic workouts on this device'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () async {
                      await activityProv.seedSampleData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sample activities loaded successfully!'),
                            backgroundColor: AppTheme.primaryDark,
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(color: AppTheme.dividerColor),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_sweep_rounded,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    title: const Text(
                      'Clear Device Activities',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    subtitle: const Text('Permanently erase all activity records on this phone'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _confirmClearData(context, activityProv, trackerProv),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // App Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Version ${AppConstants.appVersion}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'FitTrack runs locally on this device. Anyone carrying this phone can track real-time footsteps, GPS distance, and manage activities without creating an account or personal user profile.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.dividerColor),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        AppUpdateService.promptUpdateIfAvailable(context, showNoUpdateMessage: true);
                      },
                      icon: const Icon(Icons.system_update_rounded, size: 20),
                      label: const Text(
                        'Check for App Updates',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow({
    required String title,
    required String status,
    required bool isActive,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryLight : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? AppTheme.primaryDark : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLifetimeStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

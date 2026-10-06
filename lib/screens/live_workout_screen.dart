import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../providers/realtime_tracker_provider.dart';
import '../utils/app_theme.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final String initialActivityType;

  const LiveWorkoutScreen({
    super.key,
    this.initialActivityType = 'Walking',
  });

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  late String _selectedType;
  final List<Map<String, dynamic>> _activities = [
    {'name': 'Walking', 'icon': Icons.directions_walk_rounded, 'color': AppTheme.primaryColor},
    {'name': 'Running', 'icon': Icons.directions_run_rounded, 'color': AppTheme.accentOrange},
    {'name': 'Cycling', 'icon': Icons.directions_bike_rounded, 'color': AppTheme.secondaryColor},
    {'name': 'Travel', 'icon': Icons.commute_rounded, 'color': AppTheme.accentPurple},
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialActivityType;
  }

  void _confirmFinish(BuildContext context, RealtimeTrackerProvider trackerProv, ActivityProvider activityProv) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Finish Workout?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Great work! Do you want to save this session to your activity history?',
                style: Theme.of(dialogCtx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Time', trackerProv.formattedSessionDuration),
                    _buildSummaryRow('Distance', '${trackerProv.sessionDistanceKm.toStringAsFixed(2)} km'),
                    _buildSummaryRow('Steps', '${trackerProv.sessionSteps}'),
                    _buildSummaryRow('Calories', '${trackerProv.sessionCalories.toInt()} kcal'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Resume'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final success = await trackerProv.finishSession(activityProv);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '🎉 Workout saved to your database!'
                            : 'Workout session completed!',
                      ),
                      backgroundColor: AppTheme.primaryDark,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Workout'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDiscard(BuildContext context, RealtimeTrackerProvider trackerProv) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Discard Workout?'),
          content: const Text('Are you sure you want to discard this session? The tracked data will not be saved.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Keep Tracking'),
            ),
            TextButton(
              onPressed: () {
                trackerProv.discardSession();
                Navigator.pop(dialogCtx);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackerProv = Provider.of<RealtimeTrackerProvider>(context);
    final activityProv = Provider.of<ActivityProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          trackerProv.isSessionActive
              ? 'Tracking $_selectedType'
              : 'Live Activity Tracker',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (trackerProv.isSessionActive)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Discard',
              onPressed: () => _confirmDiscard(context, trackerProv),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusChip(
                      icon: Icons.gps_fixed_rounded,
                      label: trackerProv.isGpsActive ? 'GPS Active' : 'GPS Ready',
                      isActive: trackerProv.isGpsActive,
                    ),
                    Container(height: 20, width: 1, color: AppTheme.dividerColor),
                    _buildStatusChip(
                      icon: Icons.directions_walk_rounded,
                      label: trackerProv.isStepSensorActive ? 'Sensor Active' : 'Step Counter',
                      isActive: trackerProv.isStepSensorActive,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (!trackerProv.hasPermissions)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.accentOrange),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Permissions required for step counter and GPS tracking while moving.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: () => trackerProv.requestPermissions(),
                        child: const Text('Grant', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentOrange)),
                      ),
                    ],
                  ),
                ),

              if (!trackerProv.isSessionActive) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Activity Type',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _activities.map((act) {
                    final isSelected = _selectedType == act['name'];
                    final color = act['color'] as Color;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = act['name'] as String;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? color : AppTheme.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(act['icon'] as IconData, color: isSelected ? color : AppTheme.textSecondary, size: 24),
                              const SizedBox(height: 4),
                              Text(
                                act['name'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? color : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), AppTheme.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: trackerProv.isSessionActive
                                ? (trackerProv.isSessionPaused ? Colors.amber : Colors.greenAccent)
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          trackerProv.isSessionActive
                              ? (trackerProv.isSessionPaused ? 'PAUSED' : 'TRACKING LIVE')
                              : 'READY TO TRACK',
                          style: const TextStyle(
                            color: Colors.white70,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      trackerProv.isSessionActive ? trackerProv.formattedSessionDuration : '00:00',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ELAPSED TIME',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.place_rounded, color: AppTheme.secondaryColor, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'DISTANCE TRAVELED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          trackerProv.isSessionActive
                              ? trackerProv.sessionDistanceKm.toStringAsFixed(2)
                              : '0.00',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'km',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.directions_walk_rounded,
                      color: AppTheme.primaryColor,
                      label: 'Footsteps',
                      value: trackerProv.isSessionActive ? '${trackerProv.sessionSteps}' : '0',
                      unit: 'steps',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.local_fire_department_rounded,
                      color: AppTheme.accentOrange,
                      label: 'Calories',
                      value: trackerProv.isSessionActive ? '${trackerProv.sessionCalories.toInt()}' : '0',
                      unit: 'kcal',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.speed_rounded,
                      color: AppTheme.accentPurple,
                      label: 'Speed',
                      value: trackerProv.isSessionActive
                          ? trackerProv.sessionSpeedKmh.toStringAsFixed(1)
                          : '0.0',
                      unit: 'km/h',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              if (!trackerProv.isSessionActive)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    onPressed: () {
                      trackerProv.startSession(_selectedType);
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text(
                      'Start Tracking $_selectedType',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: trackerProv.isSessionPaused ? AppTheme.primaryColor : AppTheme.accentOrange,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            if (trackerProv.isSessionPaused) {
                              trackerProv.resumeSession();
                            } else {
                              trackerProv.pauseSession();
                            }
                          },
                          icon: Icon(
                            trackerProv.isSessionPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                            color: trackerProv.isSessionPaused ? AppTheme.primaryColor : AppTheme.accentOrange,
                          ),
                          label: Text(
                            trackerProv.isSessionPaused ? 'Resume' : 'Pause',
                            style: TextStyle(
                              color: trackerProv.isSessionPaused ? AppTheme.primaryColor : AppTheme.accentOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                          ),
                          onPressed: () => _confirmFinish(context, trackerProv, activityProv),
                          icon: const Icon(Icons.stop_rounded, size: 26),
                          label: const Text(
                            'Finish & Save',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

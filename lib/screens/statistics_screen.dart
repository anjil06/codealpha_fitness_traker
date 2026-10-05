import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../services/fitness_service.dart';
import '../utils/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activityProv = Provider.of<ActivityProvider>(context);
    final theme = Theme.of(context);
    final weekly = activityProv.weeklySummaries;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Statistics & Insights'),
      ),
      body: RefreshIndicator(
        onRefresh: () => activityProv.loadActivities(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(theme, "Today's Summary", Icons.today_rounded),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      theme: theme,
                      label: 'Steps',
                      value: '${activityProv.todaySteps}',
                      icon: Icons.directions_walk_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      theme: theme,
                      label: 'Calories',
                      value: '${activityProv.todayCalories.toInt()} kcal',
                      icon: Icons.local_fire_department_rounded,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      theme: theme,
                      label: 'Workout',
                      value: '${activityProv.todayDuration} min',
                      icon: Icons.timer_rounded,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      theme: theme,
                      label: 'Distance',
                      value: '${activityProv.todayDistance.toStringAsFixed(1)} km',
                      icon: Icons.place_rounded,
                      color: AppTheme.accentPurple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _buildSectionHeader(theme, 'Weekly Overview (Last 7 Days)', Icons.date_range_rounded),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Total Weekly Steps', '${activityProv.weeklyTotalSteps} steps', AppTheme.primaryColor),
                    const Divider(height: 20, color: AppTheme.dividerColor),
                    _buildStatRow('Total Calories Burned', '${activityProv.weeklyTotalCalories.toInt()} kcal', AppTheme.accentOrange),
                    const Divider(height: 20, color: AppTheme.dividerColor),
                    _buildStatRow('Total Workout Time', '${activityProv.weeklyTotalMinutes} min', AppTheme.secondaryColor),
                    const Divider(height: 20, color: AppTheme.dividerColor),
                    _buildStatRow('Average Daily Steps', '${activityProv.weeklyAvgSteps} steps / day', AppTheme.primaryDark),
                    const Divider(height: 20, color: AppTheme.dividerColor),
                    _buildStatRow('Average Daily Calories', '${activityProv.weeklyAvgCalories} kcal / day', AppTheme.accentOrange),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _buildChartCard(
                context: context,
                title: 'Weekly Steps',
                subtitle: 'Daily steps breakdown for the past 7 days',
                color: AppTheme.primaryColor,
                unit: 'steps',
                summaries: weekly,
                getValue: (day) => day.steps.toDouble(),
              ),

              const SizedBox(height: 20),

              _buildChartCard(
                context: context,
                title: 'Weekly Calories',
                subtitle: 'Daily calories burned across workouts',
                color: AppTheme.accentOrange,
                unit: 'kcal',
                summaries: weekly,
                getValue: (day) => day.calories,
              ),

              const SizedBox(height: 20),

              _buildChartCard(
                context: context,
                title: 'Weekly Workout Duration',
                subtitle: 'Minutes of active exercise per day',
                color: AppTheme.secondaryColor,
                unit: 'min',
                summaries: weekly,
                getValue: (day) => day.workoutMinutes.toDouble(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required String unit,
    required List<DaySummary> summaries,
    required double Function(DaySummary) getValue,
  }) {
    final theme = Theme.of(context);

    double maxY = 10;
    for (final s in summaries) {
      final v = getValue(s);
      if (v > maxY) maxY = v;
    }
    maxY = maxY * 1.25;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: summaries.isEmpty
                ? const Center(child: Text('No data recorded yet'))
                : BarChart(
                    BarChartData(
                      maxY: maxY,
                      minY: 0,
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.textPrimary,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final day = summaries[group.x.toInt()];
                            final val = rod.toY.toInt();
                            return BarTooltipItem(
                              '${day.dayLabel}\n$val $unit',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == meta.max) {
                                return const SizedBox.shrink();
                              }
                              String text;
                              if (value >= 1000) {
                                text = '${(value / 1000).toStringAsFixed(1)}k';
                              } else {
                                text = value.toInt().toString();
                              }
                              return Text(
                                text,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < summaries.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    summaries[index].dayLabel,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: math.max(1, (maxY / 4).roundToDouble()),
                        getDrawingHorizontalLine: (value) => const FlLine(
                          color: AppTheme.dividerColor,
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: List.generate(summaries.length, (index) {
                        final val = getValue(summaries[index]);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: val,
                              color: color,
                              width: 14,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color: color.withAlpha(18),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

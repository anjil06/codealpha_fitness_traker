import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/fitness_service.dart';
import '../utils/app_theme.dart';

enum ChartMetric { steps, calories, minutes }

class WeeklyChart extends StatefulWidget {
  final List<DaySummary> weeklySummaries;

  const WeeklyChart({
    super.key,
    required this.weeklySummaries,
  });

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  ChartMetric _selectedMetric = ChartMetric.steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metricColor = _getMetricColor(_selectedMetric);

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
                'Weekly Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMetricTab('Steps', ChartMetric.steps),
                    _buildMetricTab('Calories', ChartMetric.calories),
                    _buildMetricTab('Time', ChartMetric.minutes),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                _getMetricSummaryText(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: metricColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: widget.weeklySummaries.isEmpty
                ? const Center(child: Text('No data for this week'))
                : BarChart(
                    _buildBarChartData(metricColor),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTab(String label, ChartMetric metric) {
    final isSelected = _selectedMetric == metric;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = metric;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  String _getMetricSummaryText() {
    double total = 0;
    for (final s in widget.weeklySummaries) {
      if (_selectedMetric == ChartMetric.steps) {
        total += s.steps;
      } else if (_selectedMetric == ChartMetric.calories) {
        total += s.calories;
      } else {
        total += s.workoutMinutes;
      }
    }

    switch (_selectedMetric) {
      case ChartMetric.steps:
        return 'Total: ${total.toInt()} steps this week';
      case ChartMetric.calories:
        return 'Total: ${total.toInt()} kcal burned';
      case ChartMetric.minutes:
        return 'Total: ${total.toInt()} workout mins';
    }
  }

  Color _getMetricColor(ChartMetric metric) {
    switch (metric) {
      case ChartMetric.steps:
        return AppTheme.primaryColor;
      case ChartMetric.calories:
        return AppTheme.accentOrange;
      case ChartMetric.minutes:
        return AppTheme.secondaryColor;
    }
  }

  BarChartData _buildBarChartData(Color barColor) {
    double maxY = 10;
    for (final day in widget.weeklySummaries) {
      double val = 0;
      if (_selectedMetric == ChartMetric.steps) {
        val = day.steps.toDouble();
      } else if (_selectedMetric == ChartMetric.calories) {
        val = day.calories;
      } else {
        val = day.workoutMinutes.toDouble();
      }
      if (val > maxY) maxY = val;
    }
    maxY = maxY * 1.2;

    return BarChartData(
      maxY: maxY,
      minY: 0,
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => AppTheme.textPrimary,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final day = widget.weeklySummaries[group.x.toInt()];
            String unit = '';
            String valStr = '';
            if (_selectedMetric == ChartMetric.steps) {
              unit = 'steps';
              valStr = rod.toY.toInt().toString();
            } else if (_selectedMetric == ChartMetric.calories) {
              unit = 'kcal';
              valStr = '${rod.toY.toInt()}';
            } else {
              unit = 'min';
              valStr = '${rod.toY.toInt()}';
            }
            return BarTooltipItem(
              '${day.dayLabel}\n$valStr $unit',
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
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.weeklySummaries.length) {
                final label = widget.weeklySummaries[index].dayLabel;
                final isToday = index == widget.weeklySummaries.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isToday ? AppTheme.primaryColor : AppTheme.textSecondary,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
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
      barGroups: List.generate(widget.weeklySummaries.length, (index) {
        final day = widget.weeklySummaries[index];
        double val = 0;
        if (_selectedMetric == ChartMetric.steps) {
          val = day.steps.toDouble();
        } else if (_selectedMetric == ChartMetric.calories) {
          val = day.calories;
        } else {
          val = day.workoutMinutes.toDouble();
        }

        final isToday = index == widget.weeklySummaries.length - 1;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: val,
              color: isToday ? barColor : barColor.withAlpha(180),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: barColor.withAlpha(20),
              ),
            ),
          ],
        );
      }),
    );
  }
}

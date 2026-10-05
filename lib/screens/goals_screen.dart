import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../utils/app_theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _stepsController;
  late TextEditingController _caloriesController;
  late TextEditingController _workoutController;
  late TextEditingController _distanceController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final goal = Provider.of<GoalProvider>(context, listen: false).goal;

    _stepsController = TextEditingController(text: goal.steps.toString());
    _caloriesController =
        TextEditingController(text: goal.calories.toInt().toString());
    _workoutController =
        TextEditingController(text: goal.workoutMinutes.toString());
    _distanceController =
        TextEditingController(text: goal.distance.toString());
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _workoutController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final steps = int.parse(_stepsController.text.trim());
    final calories = double.parse(_caloriesController.text.trim());
    final workout = int.parse(_workoutController.text.trim());
    final distance = double.parse(_distanceController.text.trim());

    final goalProv = Provider.of<GoalProvider>(context, listen: false);
    final success = await goalProv.updateGoal(
      steps: steps,
      calories: calories,
      workoutMinutes: workout,
      distance: distance,
    );

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily goals updated successfully!'),
          backgroundColor: AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update goals.'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetToDefaults() {
    setState(() {
      _stepsController.text = '10000';
      _caloriesController.text = '700';
      _workoutController.text = '60';
      _distanceController.text = '5.0';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Daily Fitness Goals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: const Text('Defaults'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customize Your Targets',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set daily fitness targets to track your progress on the dashboard.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              _buildGoalField(
                label: 'Daily Steps Goal',
                hint: 'e.g. 10000',
                unit: 'steps',
                controller: _stepsController,
                icon: Icons.directions_walk_rounded,
                color: AppTheme.primaryColor,
                isDecimal: false,
              ),

              const SizedBox(height: 20),

              _buildGoalField(
                label: 'Daily Calories Goal',
                hint: 'e.g. 700',
                unit: 'kcal',
                controller: _caloriesController,
                icon: Icons.local_fire_department_rounded,
                color: AppTheme.accentOrange,
                isDecimal: true,
              ),

              const SizedBox(height: 20),

              _buildGoalField(
                label: 'Daily Workout Time',
                hint: 'e.g. 60',
                unit: 'minutes',
                controller: _workoutController,
                icon: Icons.timer_rounded,
                color: AppTheme.secondaryColor,
                isDecimal: false,
              ),

              const SizedBox(height: 20),

              _buildGoalField(
                label: 'Daily Distance Goal',
                hint: 'e.g. 5.0',
                unit: 'km',
                controller: _distanceController,
                icon: Icons.place_rounded,
                color: AppTheme.accentPurple,
                isDecimal: true,
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveGoals,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Goals',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalField({
    required String label,
    required String hint,
    required String unit,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required bool isDecimal,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Unit: $unit',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
            inputFormatters: isDecimal
                ? []
                : [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: hint,
              suffixText: unit,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a goal value';
              }
              final val = double.tryParse(value.trim());
              if (val == null || val <= 0) {
                return 'Goal must be greater than 0';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

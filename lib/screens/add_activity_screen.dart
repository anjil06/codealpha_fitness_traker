import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../services/fitness_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class AddActivityScreen extends StatefulWidget {
  final Activity? activityToEdit;

  const AddActivityScreen({super.key, this.activityToEdit});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedExerciseType;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _distanceController;
  late TextEditingController _stepsController;
  late TextEditingController _notesController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isSubmitting = false;

  bool get _isEditing => widget.activityToEdit != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.activityToEdit;

    _selectedExerciseType = edit?.exerciseType ?? AppConstants.running;
    _durationController = TextEditingController(
      text: edit != null ? edit.duration.toString() : '',
    );
    _caloriesController = TextEditingController(
      text: edit != null ? edit.calories.toInt().toString() : '',
    );
    _distanceController = TextEditingController(
      text: edit?.distance != null ? edit!.distance.toString() : '',
    );
    _stepsController = TextEditingController(
      text: edit?.steps != null ? edit!.steps.toString() : '',
    );
    _notesController = TextEditingController(
      text: edit?.notes ?? '',
    );

    if (edit != null) {
      try {
        _selectedDate = DateTime.parse(edit.date);
      } catch (_) {
        _selectedDate = DateTime.now();
      }

      if (edit.time != null && edit.time!.isNotEmpty) {
        try {
          final parsed = DateFormat('hh:mm a').parse(edit.time!);
          _selectedTime = TimeOfDay(hour: parsed.hour, minute: parsed.minute);
        } catch (_) {
          _selectedTime = TimeOfDay.now();
        }
      } else {
        _selectedTime = TimeOfDay.now();
      }
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _distanceController.dispose();
    _stepsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateEstimatedCalories() {
    final duration = int.tryParse(_durationController.text);
    if (duration != null && duration > 0) {
      final estimated = FitnessService.estimateCalories(_selectedExerciseType, duration);
      _caloriesController.text = estimated.toInt().toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estimated $estimated kcal based on $_selectedExerciseType for $duration mins.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a duration first to estimate calories.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formattedTime() {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final duration = int.parse(_durationController.text.trim());
    final calories = double.parse(_caloriesController.text.trim());
    final distance = _distanceController.text.trim().isNotEmpty
        ? double.tryParse(_distanceController.text.trim())
        : null;
    final steps = _stepsController.text.trim().isNotEmpty
        ? int.tryParse(_stepsController.text.trim())
        : null;
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : null;

    final dateKey = FitnessService.formatDateKey(_selectedDate);
    final timeStr = _formattedTime();

    final activity = Activity(
      id: widget.activityToEdit?.id,
      exerciseType: _selectedExerciseType,
      duration: duration,
      calories: calories,
      distance: distance,
      steps: steps,
      date: dateKey,
      time: timeStr,
      notes: notes,
    );

    final provider = Provider.of<ActivityProvider>(context, listen: false);
    bool success;

    if (_isEditing) {
      success = await provider.updateActivity(activity);
    } else {
      success = await provider.addActivity(activity);
    }

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Activity updated successfully!'
                : 'Activity added successfully!',
          ),
          backgroundColor: AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save activity.'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exerciseColor = AppConstants.getExerciseColor(_selectedExerciseType);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Activity' : 'Add Activity',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exercise Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedExerciseType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: AppConstants.exerciseTypes.map((type) {
                      final itemColor = AppConstants.getExerciseColor(type);
                      final itemIcon = AppConstants.getExerciseIcon(type);
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: itemColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(itemIcon, color: itemColor, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              type,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedExerciseType = val;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration (min) *',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            hintText: 'e.g. 45',
                            prefixIcon: Icon(Icons.timer_outlined, size: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter duration';
                            }
                            final val = int.tryParse(value.trim());
                            if (val == null || val <= 0) {
                              return 'Must be > 0';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Calories (kcal) *',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: _calculateEstimatedCalories,
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  'Auto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _caloriesController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: 'e.g. 350',
                            prefixIcon: Icon(Icons.local_fire_department_outlined, size: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter calories';
                            }
                            final val = double.tryParse(value.trim());
                            if (val == null || val < 0) {
                              return 'Invalid kcal';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distance (km)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _distanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: 'Optional (e.g. 5.2)',
                            prefixIcon: Icon(Icons.place_outlined, size: 20),
                          ),
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final val = double.tryParse(value.trim());
                              if (val == null || val < 0) {
                                return 'Invalid km';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Steps',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stepsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            hintText: 'Optional (e.g. 6000)',
                            prefixIcon: Icon(Icons.directions_walk_outlined, size: 20),
                          ),
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final val = int.tryParse(value.trim());
                              if (val == null || val < 0) {
                                return 'Invalid steps';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    DateFormat('MMM d, yyyy').format(_selectedDate),
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 18, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formattedTime(),
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Notes (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'How did your workout go?',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: exerciseColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Activity' : 'Save Activity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

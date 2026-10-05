import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/activity_card.dart';
import '../widgets/empty_state.dart';
import 'add_activity_screen.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityProv = Provider.of<ActivityProvider>(context);

    List<Activity> filtered = activityProv.activities.where((act) {
      final matchesFilter =
          _selectedFilter == 'All' || act.exerciseType == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          act.exerciseType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (act.notes != null &&
              act.notes!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          IconButton(
            tooltip: 'Add Activity',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddActivityScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => activityProv.loadActivities(),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search workouts, notes...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        ...AppConstants.exerciseTypes.map(
                          (type) => _buildFilterChip(type),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: activityProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: EmptyState(
                              title: _selectedFilter == 'All' && _searchQuery.isEmpty
                                  ? 'No activities logged'
                                  : 'No matching activities',
                              message: _selectedFilter == 'All' && _searchQuery.isEmpty
                                  ? 'Start tracking your workouts to see your history here.'
                                  : 'Try adjusting your filters or search keywords.',
                              onActionPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AddActivityScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final act = filtered[index];
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
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primaryLight,
        checkmarkColor: AppTheme.primaryDark,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppTheme.primaryDark : AppTheme.textSecondary,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }
}

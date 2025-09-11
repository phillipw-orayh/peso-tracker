import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ipon_gpt/shared/widgets/settings_launcher.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/providers/goal_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/models/savings_goal.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_stats_card.dart';
import '../../../core/services/celebration_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();

    // Set context for goal celebrations and initialize celebration service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().setContext(context);
      CelebrationService.initialize(this);
      _loadGoals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    CelebrationService.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    await context.read<GoalProvider>().loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocaleProvider>(
          builder: (context, locale, child) => Text(
            locale.getLocalizedText('my_goals'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => SettingsLauncher.show(context: context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Short'),
            Tab(text: 'Medium'),
            Tab(text: 'Long'),
          ],
        ),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          return CelebrationHelper.buildWithCelebrations(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGoalsList(goalProvider.goals,
                    showRefreshIndicator: true, showStats: true),
                _buildGoalsList(goalProvider.goals
                    .where((g) => g.type == GoalType.shortTerm)
                    .toList()),
                _buildGoalsList(goalProvider.goals
                    .where((g) => g.type == GoalType.mediumTerm)
                    .toList()),
                _buildGoalsList(goalProvider.goals
                    .where((g) => g.type == GoalType.longTerm)
                    .toList()),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NavigationService.goToAddGoal(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.flag, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildGoalsList(List<SavingsGoal> goals,
      {bool showRefreshIndicator = false, bool showStats = false}) {
    if (goals.isEmpty) {
      return _buildEmptyState(showStats: showStats);
    }

    // Sort goals by progress (completed first, then by progress percentage)
    goals.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return -1;
      if (!a.isCompleted && b.isCompleted) return 1;
      return b.progressPercentage.compareTo(a.progressPercentage);
    });

    final listView = ListView.builder(
      controller: showRefreshIndicator ? _scrollController : null,
      padding: EdgeInsets.zero,
      itemCount: goals.length + (showStats ? 1 : 0),
      itemBuilder: (context, index) {
        if (showStats && index == 0) {
          // Stats card as first item
          return Container(
            color: AppConstants.primaryColor,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GoalStatsCard(),
            ),
          );
        }

        final goalIndex = showStats ? index - 1 : index;
        final goal = goals[goalIndex];
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            goalIndex == 0 ? AppConstants.largePadding : AppConstants.defaultPadding,
            AppConstants.defaultPadding,
            AppConstants.defaultPadding,
          ),
          child: GoalCard(
            goal: goal,
            onTap: () => _showGoalDetails(goal),
          ),
        );
      },
    );

    if (showRefreshIndicator) {
      return RefreshIndicator(
        onRefresh: _loadGoals,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildEmptyState({bool showStats = false}) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return ListView(
          children: [
            if (showStats)
              Container(
                color: AppConstants.primaryColor,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GoalStatsCard(),
                ),
              ),
            const SizedBox(height: AppConstants.defaultPadding),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      locale.getLocalizedText('no_goals_yet'),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      locale.getLocalizedText('create_first_goal'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    ElevatedButton.icon(
                      onPressed: () => NavigationService.goToAddGoal(),
                      icon: const Icon(Icons.add),
                      label: Text(locale.getLocalizedText('create_goal')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.largePadding,
                          vertical: AppConstants.defaultPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultBorderRadius),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGoalDetails(SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGoalDetailsSheet(goal),
    );
  }

  Widget _buildGoalDetailsSheet(SavingsGoal goal) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pop(context);
                    NavigationService.goToEditGoal(goal.id);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Section
                  _buildProgressSection(goal),
                  const SizedBox(height: AppConstants.largePadding),

                  // Details Section
                  _buildDetailsSection(goal),
                  const SizedBox(height: AppConstants.largePadding),

                  // Action Buttons
                  _buildActionButtons(goal),
                  const SizedBox(height: AppConstants.largePadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(SavingsGoal goal) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              Text(
                '${goal.progressPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          LinearProgressIndicator(
            value: goal.progressPercentage / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            minHeight: 8,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₱${goal.savedAmount.toStringAsFixed(0)}'),
              Text('₱${goal.targetAmount.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(SavingsGoal goal) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Description', goal.description),
        _buildDetailRow(
            'Target Amount', '₱${goal.targetAmount.toStringAsFixed(0)}'),
        _buildDetailRow(
            'Saved Amount', '₱${goal.savedAmount.toStringAsFixed(0)}'),
        _buildDetailRow('Remaining',
            '₱${(goal.targetAmount - goal.savedAmount).toStringAsFixed(0)}'),
        _buildDetailRow(
            'Days Left', daysLeft > 0 ? '$daysLeft days' : 'Overdue'),
        _buildDetailRow('Created',
            '${goal.createdDate.day}/${goal.createdDate.month}/${goal.createdDate.year}'),
        _buildDetailRow('Target Date',
            '${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SavingsGoal goal) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showAddSavingsDialog(goal);
            },
            icon: const Icon(Icons.savings),
            label: const Text('Add Savings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        if (!goal.isCompleted)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _deleteGoal(goal);
              },
              icon: const Icon(Icons.delete_outline,
                  color: AppConstants.errorColor),
              label: const Text('Delete Goal'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.errorColor,
                side: const BorderSide(color: AppConstants.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAddSavingsDialog(SavingsGoal goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Savings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add savings to "${goal.title}"'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱ ',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                context.read<GoalProvider>().addSavings(goal.id, amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Savings added successfully!'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
            'Are you sure you want to delete "${goal.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GoalProvider>().deleteGoal(goal.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Goal deleted successfully'),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

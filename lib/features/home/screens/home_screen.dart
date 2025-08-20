import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peso_tracker/shared/widgets/settings_launcher.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/goal_provider.dart';
import '../../../shared/providers/gamification_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/goals_preview_card.dart';
import '../widgets/streak_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<ExpenseProvider>().loadExpenses(),
      context.read<GoalProvider>().loadGoals(),
      context.read<GamificationProvider>().loadUserData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Consumer<LocaleProvider>(
          builder: (context, locale, child) {
            return Text(
              locale.isFilipino
                  ? 'Kumusta, ${_getUserName()}!'
                  : 'Hello, ${_getUserName()}!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => SettingsLauncher.show(context: context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StreakCard(),
              const SizedBox(height: AppConstants.defaultPadding),
              const ExpenseSummaryCard(),
              const SizedBox(height: AppConstants.defaultPadding),
              const GoalsPreviewCard(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildQuickActions(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildRecentExpenses(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NavigationService.goToAddExpense(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }

  String _getUserName() {
    final userData = context.watch<GamificationProvider>().userData;
    return userData?.name ?? 'User';
  }

  Widget _buildQuickActions() {
    return Consumer<LocaleProvider>(
      builder: (context, locale, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.getLocalizedText('quick_actions'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.add_circle_outline,
                    title: locale.getLocalizedText('add_expense'),
                    onTap: () => NavigationService.goToAddExpense(),
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.flag_outlined,
                    title: locale.getLocalizedText('new_goal'),
                    onTap: () => NavigationService.goToAddGoal(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentExpenses() {
    return Consumer2<ExpenseProvider, LocaleProvider>(
      builder: (context, expenseProvider, locale, child) {
        final recentExpenses = expenseProvider.expenses.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  locale.getLocalizedText('recent_expenses'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () => NavigationService.goToExpenses(),
                  child: Text(locale.getLocalizedText('see_all')),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            if (recentExpenses.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Center(
                    child: Text(
                      locale.getLocalizedText('no_expenses_yet'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...recentExpenses.map((expense) => Card(
                    margin: const EdgeInsets.only(
                        bottom: AppConstants.smallPadding),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppConstants.primaryColor.withOpacity(0.1),
                        child: Icon(
                          _getCategoryIcon(expense.category),
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      title: Text(expense.description),
                      subtitle: Text(expense.category),
                      trailing: Text(
                        locale.formatCurrency(expense.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pagkain':
        return Icons.restaurant;
      case 'transportasyon':
        return Icons.directions_bus;
      case 'bills':
        return Icons.receipt_long;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/goal_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/models/savings_goal.dart';
import '../../../core/constants/app_constants.dart';

class GoalStatsCard extends StatelessWidget {
  const GoalStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GoalProvider, LocaleProvider>(
      builder: (context, goalProvider, locale, child) {
        final goals = goalProvider.goals;
        final activeGoals = goals.where((g) => !g.isCompleted).toList();
        final completedGoals = goals.where((g) => g.isCompleted).toList();
        final totalSaved = goals.fold<double>(0, (sum, goal) => sum + goal.savedAmount);
        final totalTarget = goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
        final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.bar_chart,
                      color: AppConstants.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      locale.getLocalizedText('goal_statistics'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Stats Grid
                if (goals.isNotEmpty) ...[
                  // Overall Progress
                  _buildOverallProgress(overallProgress, totalSaved, totalTarget),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.flag,
                          label: 'Active Goals',
                          value: activeGoals.length.toString(),
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          label: 'Completed',
                          value: completedGoals.length.toString(),
                          color: AppConstants.successColor,
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.savings,
                          label: 'Total Saved',
                          value: '₱${_formatAmount(totalSaved)}',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // Goal Type Breakdown
                  _buildGoalTypeBreakdown(goals),
                ] else
                  _buildEmptyStats(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverallProgress(double progress, double saved, double target) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              Text(
                '${progress.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₱${_formatAmount(saved)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₱${_formatAmount(target)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTypeBreakdown(List<SavingsGoal> goals) {
    final shortTermGoals = goals.where((g) => g.type == GoalType.shortTerm).length;
    final mediumTermGoals = goals.where((g) => g.type == GoalType.mediumTerm).length;
    final longTermGoals = goals.where((g) => g.type == GoalType.longTerm).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goals by Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeIndicator('Short', shortTermGoals, Colors.green),
            ),
            Expanded(
              child: _buildTypeIndicator('Medium', mediumTermGoals, Colors.orange),
            ),
            Expanded(
              child: _buildTypeIndicator('Long', longTermGoals, Colors.purple),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeIndicator(String label, int count, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '$label ($count)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStats() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'No goals yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Create your first goal to see statistics here',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
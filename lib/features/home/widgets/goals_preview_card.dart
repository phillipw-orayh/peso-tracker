import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/goal_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';

class GoalsPreviewCard extends StatelessWidget {
  const GoalsPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GoalProvider, LocaleProvider>(
      builder: (context, goalProvider, locale, child) {
        final activeGoals = goalProvider.activeGoals;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale.getLocalizedText('savings_goals'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () => NavigationService.goToGoals(),
                      child: Text(locale.getLocalizedText('see_all')),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                if (activeGoals.isEmpty)
                  _buildEmptyState(locale)
                else
                  Column(
                    children: [
                      _buildOverallProgress(goalProvider, locale),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ...activeGoals.take(2).map((goal) => Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                        child: _buildGoalItem(goal, locale),
                      )),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(LocaleProvider locale) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            locale.getLocalizedText('no_goals_yet'),
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ElevatedButton(
            onPressed: () => NavigationService.goToAddGoal(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(locale.getLocalizedText('create_first_goal')),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(GoalProvider goalProvider, LocaleProvider locale) {
    final progress = goalProvider.totalSavingsProgress;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.getLocalizedText('total_progress'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                '${progress.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '${locale.formatCurrency(goalProvider.totalCurrentSavings)} of ${locale.formatCurrency(goalProvider.totalSavingsGoalAmount)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(dynamic goal, LocaleProvider locale) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${goal.progressPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
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
            valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${locale.formatCurrency(goal.currentAmount)} / ${locale.formatCurrency(goal.targetAmount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              Text(
                '${goal.daysRemaining} ${locale.getLocalizedText('days')} left',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../shared/models/savings_goal.dart';
import '../../../core/constants/app_constants.dart';

class GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = goal.progressPercentage / 100;
    final isCompleted = goal.isCompleted;
    final isOverdue = !isCompleted && goal.targetDate.isBefore(DateTime.now());
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        side: BorderSide(
          color: isCompleted 
            ? AppConstants.successColor 
            : isOverdue 
              ? AppConstants.errorColor 
              : Colors.transparent,
          width: isCompleted || isOverdue ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with goal type and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getGoalTypeColor(goal.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getGoalTypeText(goal.type),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getGoalTypeColor(goal.type),
                      ),
                    ),
                  ),
                  _buildStatusIndicator(),
                ],
              ),
              
              const SizedBox(height: AppConstants.smallPadding),
              
              // Goal title
              Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppConstants.smallPadding),
              
              // Goal description
              if (goal.description.isNotEmpty)
                Text(
                  goal.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Progress section
              _buildProgressSection(),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Amount and date info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '₱${goal.savedAmount.toStringAsFixed(0)} / ₱${goal.targetAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Target Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? AppConstants.errorColor : AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final progressValue = goal.progressPercentage / 100;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${goal.progressPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            goal.isCompleted 
              ? AppConstants.successColor 
              : AppConstants.primaryColor,
          ),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    if (goal.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppConstants.successColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      );
    }
    
    final isOverdue = goal.targetDate.isBefore(DateTime.now());
    if (isOverdue) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppConstants.errorColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning,
          color: Colors.white,
          size: 16,
        ),
      );
    }
    
    // In progress
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.trending_up,
        color: AppConstants.primaryColor,
        size: 16,
      ),
    );
  }

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.shortTerm:
        return Colors.green;
      case GoalType.mediumTerm:
        return Colors.orange;
      case GoalType.longTerm:
        return Colors.purple;
    }
  }

  String _getGoalTypeText(GoalType type) {
    switch (type) {
      case GoalType.shortTerm:
        return 'SHORT TERM';
      case GoalType.mediumTerm:
        return 'MEDIUM TERM';
      case GoalType.longTerm:
        return 'LONG TERM';
    }
  }
}
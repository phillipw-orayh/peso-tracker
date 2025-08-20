import 'package:flutter/material.dart';
import '../../../shared/models/challenge.dart';
import '../../../core/constants/app_constants.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final UserChallenge? userChallenge;
  final bool isEnrolled;
  final double progress;
  final VoidCallback onToggle;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.userChallenge,
    required this.isEnrolled,
    required this.progress,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = userChallenge?.isCompleted ?? false;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        side: BorderSide(
          color: isCompleted 
            ? AppConstants.successColor 
            : isEnrolled 
              ? AppConstants.primaryColor 
              : Colors.transparent,
          width: isCompleted || isEnrolled ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Challenge icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getChallengeTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  child: Text(
                    challenge.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                
                const SizedBox(width: AppConstants.defaultPadding),
                
                // Challenge info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTypeChip(),
                          const SizedBox(width: 8),
                          _buildCategoryChip(),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status indicator
                _buildStatusIndicator(),
              ],
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Description
            Text(
              challenge.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Progress section (only show if enrolled)
            if (isEnrolled) ...[
              _buildProgressSection(),
              const SizedBox(height: AppConstants.defaultPadding),
            ],
            
            // Rewards section
            _buildRewardsSection(),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCompleted ? null : onToggle,
                icon: Icon(_getButtonIcon()),
                label: Text(_getButtonText()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted 
                    ? AppConstants.successColor 
                    : isEnrolled 
                      ? AppConstants.errorColor 
                      : AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppConstants.successColor.withOpacity(0.6),
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    final color = _getChallengeTypeColor();
    final text = challenge.type.toString().split('.').last.toUpperCase();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getCategoryDisplayName(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (userChallenge?.isCompleted ?? false) {
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
    
    if (isEnrolled) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.timer,
          color: AppConstants.primaryColor,
          size: 16,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildProgressSection() {
    if (userChallenge?.isCompleted ?? false) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: AppConstants.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.celebration,
              color: AppConstants.successColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Challenge completed! 🎉',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.successColor,
                ),
              ),
            ),
            if (userChallenge?.completedDate != null)
              Text(
                _formatDate(userChallenge!.completedDate!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${challenge.pointsReward} points',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (challenge.badgeReward != null) ...[
            const Icon(
              Icons.military_tech,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            const Text(
              'Badge',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.amber,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getChallengeTypeColor() {
    switch (challenge.type) {
      case ChallengeType.daily:
        return Colors.green;
      case ChallengeType.weekly:
        return Colors.orange;
      case ChallengeType.monthly:
        return Colors.purple;
    }
  }

  String _getCategoryDisplayName() {
    switch (challenge.category) {
      case ChallengeCategory.spending:
        return 'Spending';
      case ChallengeCategory.savings:
        return 'Savings';
      case ChallengeCategory.goals:
        return 'Goals';
      case ChallengeCategory.habits:
        return 'Habits';
      case ChallengeCategory.social:
        return 'Social';
    }
  }

  IconData _getButtonIcon() {
    if (userChallenge?.isCompleted ?? false) {
      return Icons.check_circle;
    } else if (isEnrolled) {
      return Icons.exit_to_app;
    } else {
      return Icons.play_arrow;
    }
  }

  String _getButtonText() {
    if (userChallenge?.isCompleted ?? false) {
      return 'Completed';
    } else if (isEnrolled) {
      return 'Leave Challenge';
    } else {
      return 'Join Challenge';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
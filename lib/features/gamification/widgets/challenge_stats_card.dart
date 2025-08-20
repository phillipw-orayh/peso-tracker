import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/challenge_provider.dart';
import '../../../shared/providers/gamification_provider.dart';
import '../../../core/constants/app_constants.dart';

class ChallengeStatsCard extends StatelessWidget {
  const ChallengeStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChallengeProvider, GamificationProvider>(
      builder: (context, challengeProvider, gamificationProvider, child) {
        final totalPoints = challengeProvider.totalPoints;
        final activeChallenges = challengeProvider.activeChallenges.length;
        final completedChallenges = challengeProvider.completedChallenges.length;
        final earnedBadges = challengeProvider.earnedBadges.length;
        final currentStreak = gamificationProvider.userData?.currentStreak ?? 0;

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
                      Icons.emoji_events,
                      color: AppConstants.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Challenge Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.stars,
                        label: 'Points',
                        value: totalPoints.toString(),
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.timer,
                        label: 'Active',
                        value: activeChallenges.toString(),
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle,
                        label: 'Done',
                        value: completedChallenges.toString(),
                        color: AppConstants.successColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.smallPadding),
                
                // Second row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.military_tech,
                        label: 'Badges',
                        value: earnedBadges.toString(),
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value: '$currentStreak days',
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.trending_up,
                        label: 'Level',
                        value: _calculateLevel(totalPoints).toString(),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Progress to next level
                _buildLevelProgress(totalPoints),
              ],
            ),
          ),
        );
      },
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
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
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

  Widget _buildLevelProgress(int totalPoints) {
    final currentLevel = _calculateLevel(totalPoints);
    final pointsInCurrentLevel = totalPoints % 100;
    final progress = pointsInCurrentLevel / 100.0;
    final pointsToNextLevel = 100 - pointsInCurrentLevel;

    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $currentLevel',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              Text(
                '$pointsToNextLevel points to Level ${currentLevel + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  int _calculateLevel(int totalPoints) {
    return (totalPoints / 100).floor() + 1;
  }
}
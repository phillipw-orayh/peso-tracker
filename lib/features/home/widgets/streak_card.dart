import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/gamification_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../core/constants/app_constants.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GamificationProvider, LocaleProvider>(
      builder: (context, gamificationProvider, locale, child) {
        final currentStreak = gamificationProvider.currentStreak;
        final longestStreak = gamificationProvider.longestStreak;
        
        return Card(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        locale.getLocalizedText('current_streak'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$currentStreak',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              locale.getLocalizedText('days'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            locale.getLocalizedText('best'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '$longestStreak ${locale.getLocalizedText('days')}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    _getStreakMessage(currentStreak, locale),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStreakMessage(int streak, LocaleProvider locale) {
    if (streak == 0) {
      return locale.isFilipino 
          ? 'Start your streak ngayon!'
          : 'Start your streak today!';
    } else if (streak < 7) {
      return locale.isFilipino 
          ? 'Good job! Target natin 1 week!'
          : 'Keep going! Let\'s reach 1 week!';
    } else if (streak < 30) {
      return locale.isFilipino 
          ? 'Amazing! Aim natin 1 month!'
          : 'Amazing! Let\'s aim for 1 month!';
    } else {
      return locale.isFilipino 
          ? 'Grabe! Streak master ka na!'
          : 'You\'re incredible! You\'re a streak master!';
    }
  }
}
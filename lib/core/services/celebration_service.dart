import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../constants/app_constants.dart';

enum CelebrationType {
  challengeComplete,
  goalAchieved,
  badgeEarned,
  streakMilestone,
  levelUp,
}

class CelebrationService {
  static ConfettiController? _confettiController;
  
  static void initialize(TickerProvider tickerProvider) {
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  static void dispose() {
    _confettiController?.dispose();
    _confettiController = null;
  }
  
  /// Show celebration with confetti and congratulatory message
  static void celebrate(
    BuildContext context, {
    required CelebrationType type,
    required String title,
    String? subtitle,
    String emoji = '🎉',
    VoidCallback? onComplete,
  }) {
    // Trigger confetti animation
    _confettiController?.play();
    
    // Show celebration modal
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CelebrationModal(
        type: type,
        title: title,
        subtitle: subtitle,
        emoji: emoji,
        onComplete: onComplete,
      ),
    );
    
    // Auto dismiss after 4 seconds if user doesn't tap
    Future.delayed(const Duration(seconds: 4), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
        onComplete?.call();
      }
    });
  }
  
  /// Get confetti widget to overlay on screens
  static Widget getConfettiWidget() {
    if (_confettiController == null) return const SizedBox.shrink();
    
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController!,
        blastDirection: 1.5708, // radians for straight down
        particleDrag: 0.05,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.3,
        shouldLoop: false,
        colors: const [
          AppConstants.primaryColor,
          AppConstants.successColor,
          Colors.amber,
          Colors.pink,
          Colors.purple,
          Colors.orange,
        ],
        createParticlePath: _createStarPath,
      ),
    );
  }
  
  /// Create star-shaped confetti particles
  static Path _createStarPath(Size size) {
    final path = Path();
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    
    for (int i = 0; i < 5; i++) {
      final angle1 = (i * 2 * 3.141592653589793) / 5;
      final angle2 = ((i + 0.5) * 2 * 3.141592653589793) / 5;
      
      final x1 = center.dx + radius * 0.8 * cos(angle1);
      final y1 = center.dy + radius * 0.8 * sin(angle1);
      
      final x2 = center.dx + radius * 0.3 * cos(angle2);
      final y2 = center.dy + radius * 0.3 * sin(angle2);
      
      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    return path;
  }
  
  /// Quick celebrations for specific milestones
  static void celebrateChallengeComplete(
    BuildContext context, {
    required String challengeTitle,
    int? pointsEarned,
    String? badgeName,
  }) {
    String subtitle = 'Napakagaling! ';
    if (pointsEarned != null) subtitle += '+$pointsEarned points earned!';
    if (badgeName != null) subtitle += ' Badge unlocked: $badgeName';
    
    celebrate(
      context,
      type: CelebrationType.challengeComplete,
      title: 'Challenge Complete!',
      subtitle: subtitle.isNotEmpty ? subtitle : null,
      emoji: '🏆',
    );
  }
  
  static void celebrateGoalAchieved(
    BuildContext context, {
    required String goalTitle,
    required double amount,
  }) {
    celebrate(
      context,
      type: CelebrationType.goalAchieved,
      title: 'Goal Achieved!',
      subtitle: 'Congratulations on reaching ₱${amount.toStringAsFixed(0)} for "$goalTitle"! 🎯',
      emoji: '🎯',
    );
  }
  
  static void celebrateBadgeEarned(
    BuildContext context, {
    required String badgeName,
    required String badgeIcon,
  }) {
    celebrate(
      context,
      type: CelebrationType.badgeEarned,
      title: 'New Badge Earned!',
      subtitle: '$badgeIcon $badgeName - Keep up the great work!',
      emoji: '🏅',
    );
  }
  
  static void celebrateStreakMilestone(
    BuildContext context, {
    required int streakDays,
  }) {
    String subtitle = '';
    String emoji = '🔥';
    
    if (streakDays >= 100) {
      subtitle = 'Incredible! 100+ days of financial discipline! 🔥🔥🔥';
      emoji = '🔥';
    } else if (streakDays >= 50) {
      subtitle = 'Amazing! You\'ve been consistent for $streakDays days! 🌟';
      emoji = '🌟';
    } else if (streakDays >= 30) {
      subtitle = 'Fantastic! One month streak achieved! 📅';
      emoji = '📅';
    } else if (streakDays >= 7) {
      subtitle = 'Great job! One week of consistency! 👏';
      emoji = '👏';
    }
    
    celebrate(
      context,
      type: CelebrationType.streakMilestone,
      title: '$streakDays Day Streak!',
      subtitle: subtitle,
      emoji: emoji,
    );
  }
  
  static void celebrateLevelUp(
    BuildContext context, {
    required int newLevel,
  }) {
    celebrate(
      context,
      type: CelebrationType.levelUp,
      title: 'Level Up!',
      subtitle: 'Welcome to Level $newLevel! Your financial skills are growing! 📈',
      emoji: '⬆️',
    );
  }
}

class CelebrationModal extends StatelessWidget {
  final CelebrationType type;
  final String title;
  final String? subtitle;
  final String emoji;
  final VoidCallback? onComplete;
  
  const CelebrationModal({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
    required this.emoji,
    this.onComplete,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius * 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated emoji
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onComplete?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                    ),
                    child: const Text(
                      'Salamat! 🙏',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for celebration functionality
class CelebrationHelper {
  /// Add this widget to your scaffold body with Stack
  static Widget buildWithCelebrations({required Widget child}) {
    return Stack(
      children: [
        child,
        CelebrationService.getConfettiWidget(),
      ],
    );
  }
}
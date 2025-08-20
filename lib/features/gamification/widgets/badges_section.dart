import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/challenge_provider.dart';
import '../../../shared/models/challenge.dart' as challenge_models;
import '../../../core/constants/app_constants.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, child) {
        final earnedBadges = challengeProvider.earnedBadges;
        
        if (earnedBadges.isEmpty) {
          return _buildEmptyBadgesState();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earned badges grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: earnedBadges.length,
              itemBuilder: (context, index) {
                final badge = earnedBadges[index];
                return _buildBadgeCard(badge, true);
              },
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Available badges preview
            Text(
              'Available Badges',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _getAvailableBadges(earnedBadges).length,
                itemBuilder: (context, index) {
                  final badge = _getAvailableBadges(earnedBadges)[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildBadgeCard(badge, false),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyBadgesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.military_tech_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'No badges earned yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Complete challenges to earn awesome Filipino-themed badges!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Preview of available badges
          Text(
            'Available Badges:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _getAllAvailableBadges().map<Widget>((badge) => 
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildBadgeCard(badge, false),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(challenge_models.Badge badge, bool isEarned) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: isEarned ? _hexToColor(badge.color).withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: isEarned ? _hexToColor(badge.color) : Colors.grey.shade300,
          width: isEarned ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.icon,
              style: TextStyle(
                fontSize: 20,
                color: isEarned ? null : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                badge.name,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: isEarned ? _hexToColor(badge.color) : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<challenge_models.Badge> _getAvailableBadges(List<challenge_models.Badge> earnedBadges) {
    final allBadges = _getAllAvailableBadges();
    final earnedBadgeIds = earnedBadges.map((b) => b.id).toSet();
    
    return allBadges.where((badge) => !earnedBadgeIds.contains(badge.id)).toList();
  }

  List<challenge_models.Badge> _getAllAvailableBadges() {
    // Get available badges from ChallengeService
    final availableBadges = {
      'kuripot_royalty': challenge_models.Badge(
        id: 'kuripot_royalty',
        name: 'Kuripot Royalty',
        description: 'Mastered the art of staying under budget',
        icon: '👑',
        color: '#FFD700',
        earnedDate: DateTime.now(),
      ),
      'savings_superstar': challenge_models.Badge(
        id: 'savings_superstar',
        name: 'Ipon Master',
        description: 'Saved 10% of monthly income like a true Filipino',
        icon: '⭐',
        color: '#FF6B35',
        earnedDate: DateTime.now(),
      ),
      'goal_achiever': challenge_models.Badge(
        id: 'goal_achiever',
        name: 'Goal Crusher',
        description: 'Completed a savings goal against all odds',
        icon: '🏆',
        color: '#4CAF50',
        earnedDate: DateTime.now(),
      ),
      'financial_guru': challenge_models.Badge(
        id: 'financial_guru',
        name: 'Masinop na Pinoy',
        description: 'Consistently tracked expenses like a financial pro',
        icon: '🧠',
        color: '#2196F3',
        earnedDate: DateTime.now(),
      ),
      'streak_master': challenge_models.Badge(
        id: 'streak_master',
        name: 'Streak Master',
        description: 'Maintained financial discipline for weeks',
        icon: '🔥',
        color: '#FF5722',
        earnedDate: DateTime.now(),
      ),
      'budget_warrior': challenge_models.Badge(
        id: 'budget_warrior',
        name: 'Budget Warrior',
        description: 'Fought the good fight against overspending',
        icon: '⚔️',
        color: '#9C27B0',
        earnedDate: DateTime.now(),
      ),
    };
    
    return availableBadges.values.toList();
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
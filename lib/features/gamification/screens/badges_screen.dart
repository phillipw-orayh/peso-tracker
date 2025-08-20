import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peso_tracker/shared/widgets/settings_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/challenge_provider.dart';
import '../../../shared/providers/gamification_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/section_header.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocaleProvider>(
          builder: (context, locale, child) => Text(
            locale.isFilipino ? 'Mga Badge' : 'Badges',
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
          tabs: const [
            Tab(text: 'Earned'),
            Tab(text: 'Available'),
            Tab(text: 'How It Works'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarnedBadgesTab(),
          _buildAvailableBadgesTab(),
          _buildHowItWorksTab(),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildEarnedBadgesTab() {
    return Consumer2<ChallengeProvider, GamificationProvider>(
      builder: (context, challengeProvider, gamificationProvider, child) {
        final earnedBadges = challengeProvider.earnedBadges;

        if (earnedBadges.isEmpty) {
          return _buildEmptyEarnedState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          itemCount: earnedBadges.length,
          itemBuilder: (context, index) {
            final badge = earnedBadges[index];
            return _buildEarnedBadgeCard(badge);
          },
        );
      },
    );
  }

  Widget _buildAvailableBadgesTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      children: [
        _buildBadgeCategory(
          'Points Badges',
          Icons.stars,
          _getPointsBadges(),
        ),
        const SizedBox(height: AppConstants.largePadding),
        _buildBadgeCategory(
          'Challenge Badges',
          Icons.emoji_events,
          _getChallengeBadges(),
        ),
        const SizedBox(height: AppConstants.largePadding),
        _buildBadgeCategory(
          'Streak Badges',
          Icons.local_fire_department,
          _getStreakBadges(),
        ),
        const SizedBox(height: AppConstants.largePadding),
        _buildBadgeCategory(
          'Special Badges',
          Icons.diamond,
          _getSpecialBadges(),
        ),
      ],
    );
  }

  Widget _buildHowItWorksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'How to Earn Badges',
            Icons.help_outline,
            [
              'Complete challenges to earn points',
              'Maintain daily streaks',
              'Achieve specific milestones',
              'Participate in special events',
            ],
          ),
          const SizedBox(height: AppConstants.largePadding),
          _buildInfoCard(
            'Badge Types',
            Icons.category,
            [
              'Points Badges: Earned by accumulating points',
              'Challenge Badges: Unlock by completing specific challenges',
              'Streak Badges: Maintain consecutive daily activities',
              'Special Badges: Limited time or achievement rewards',
            ],
          ),
          const SizedBox(height: AppConstants.largePadding),
          _buildInfoCard(
            'Sharing Your Badges',
            Icons.share,
            [
              'Tap any earned badge to share on social media',
              'Share your progress with friends and family',
              'Inspire others to start their savings journey',
              'Show off your financial achievements',
            ],
          ),
          const SizedBox(height: AppConstants.largePadding),
          _buildTipsCard(),
        ],
      ),
    );
  }

  Widget _buildEmptyEarnedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'No Badges Earned Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Complete challenges and achieve milestones to earn your first badge!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Available Badges'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnedBadgeCard(badge) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: () => _shareBadge(badge),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppConstants.successColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.successColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Earned ${_formatDate(badge.earnedDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.share,
                color: AppConstants.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCategory(String title, IconData icon, List<BadgeInfo> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, icon: icon),
        const SizedBox(height: AppConstants.smallPadding),
        ...badges.map((badge) => _buildAvailableBadgeCard(badge)),
      ],
    );
  }

  Widget _buildAvailableBadgeCard(BadgeInfo badge) {
    return Consumer2<ChallengeProvider, GamificationProvider>(
      builder: (context, challengeProvider, gamificationProvider, child) {
        final isEarned = _isBadgeEarned(badge.id);
        final progress = _getBadgeProgress(badge, challengeProvider, gamificationProvider);
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isEarned 
                        ? AppConstants.successColor 
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEarned ? Icons.emoji_events : Icons.lock_outline,
                    color: isEarned ? Colors.white : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isEarned ? Colors.black : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (!isEarned && progress != null) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}% Complete',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isEarned)
                  Icon(
                    Icons.check_circle,
                    color: AppConstants.successColor,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<String> points) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor.withOpacity(0.1),
              AppConstants.primaryColor.withOpacity(0.05),
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
                  Icon(Icons.lightbulb_outline, color: AppConstants.primaryColor, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Pro Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              const Text(
                '💡 Log expenses daily to maintain your streak\n'
                '🎯 Focus on completing easier challenges first\n'
                '🔄 Check back regularly for new badges\n'
                '🏆 Share your achievements to stay motivated',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Badge data methods
  List<BadgeInfo> _getPointsBadges() {
    return [
      BadgeInfo('first_points', 'First Steps', 'Earn your first 10 points', 10),
      BadgeInfo('century_club', 'Century Club', 'Accumulate 100 points', 100),
      BadgeInfo('high_achiever', 'High Achiever', 'Reach 500 points', 500),
      BadgeInfo('point_master', 'Point Master', 'Earn 1000 points', 1000),
    ];
  }

  List<BadgeInfo> _getChallengeBadges() {
    return [
      BadgeInfo('challenge_starter', 'Challenge Starter', 'Complete your first challenge', 1),
      BadgeInfo('challenge_enthusiast', 'Challenge Enthusiast', 'Complete 5 challenges', 5),
      BadgeInfo('challenge_champion', 'Challenge Champion', 'Complete 15 challenges', 15),
      BadgeInfo('challenge_legend', 'Challenge Legend', 'Complete 30 challenges', 30),
    ];
  }

  List<BadgeInfo> _getStreakBadges() {
    return [
      BadgeInfo('week_warrior', 'Week Warrior', 'Maintain a 7-day streak', 7),
      BadgeInfo('month_master', 'Month Master', 'Keep a 30-day streak', 30),
      BadgeInfo('quarter_champion', 'Quarter Champion', 'Achieve a 90-day streak', 90),
      BadgeInfo('year_legend', 'Year Legend', 'Complete a 365-day streak', 365),
    ];
  }

  List<BadgeInfo> _getSpecialBadges() {
    return [
      BadgeInfo('early_bird', 'Early Bird', 'Join PesoTracker in its first month', 0),
      BadgeInfo('social_butterfly', 'Social Butterfly', 'Share 5 achievements', 5),
      BadgeInfo('goal_crusher', 'Goal Crusher', 'Complete 3 savings goals', 3),
      BadgeInfo('masinop_pinoy', 'Masinop na Pinoy', 'Master of Filipino savings', 0),
    ];
  }

  bool _isBadgeEarned(String badgeId) {
    return context.read<ChallengeProvider>().earnedBadges
        .any((badge) => badge.id == badgeId);
  }

  double? _getBadgeProgress(BadgeInfo badge, challengeProvider, gamificationProvider) {
    final userPoints = gamificationProvider.totalPoints;
    final userStreak = gamificationProvider.currentStreak;
    final completedChallenges = challengeProvider.userStats['completedChallenges'] ?? 0;

    switch (badge.id) {
      case 'first_points':
      case 'century_club':
      case 'high_achiever':
      case 'point_master':
        return (userPoints / badge.requirement).clamp(0.0, 1.0);
      
      case 'challenge_starter':
      case 'challenge_enthusiast':
      case 'challenge_champion':
      case 'challenge_legend':
        return (completedChallenges / badge.requirement).clamp(0.0, 1.0);
      
      case 'week_warrior':
      case 'month_master':
      case 'quarter_champion':
      case 'year_legend':
        return (userStreak / badge.requirement).clamp(0.0, 1.0);
      
      default:
        return null;
    }
  }

  void _shareBadge(badge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${badge.name}" badge! 🏆'),
        backgroundColor: AppConstants.successColor,
        action: SnackBarAction(
          label: 'Share',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implement actual social media sharing
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Social media sharing coming soon!'),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
  }
}

class BadgeInfo {
  final String id;
  final String name;
  final String description;
  final int requirement;

  BadgeInfo(this.id, this.name, this.description, this.requirement);
}
import 'package:flutter/material.dart';
import 'package:peso_tracker/shared/widgets/settings_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/challenge_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/models/challenge.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_stats_card.dart';
import '../widgets/badges_section.dart';
import '../../../core/services/celebration_service.dart';
import '../../../shared/widgets/bottom_navigation.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();

    // Set context for celebrations and initialize celebration service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().setContext(context);
      CelebrationService.initialize(this);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController?.dispose();
    CelebrationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocaleProvider>(
          builder: (context, locale, child) => Text(
            locale.isFilipino ? 'Mga Hamon' : 'Challenges',
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
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, challengeProvider, child) {
          if (challengeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
            );
          }

          return CelebrationHelper.buildWithCelebrations(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(showStats: true),
                _buildChallengeListTab(challengeProvider.dailyChallenges),
                _buildChallengeListTab(challengeProvider.weeklyChallenges),
                _buildChallengeListTab(challengeProvider.monthlyChallenges),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar:
          const BottomNavigation(currentIndex: 3), // Back to Profile
    );
  }

  Widget _buildOverviewTab({bool showStats = false}) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge Statistics Card
          if (showStats)
            Container(
              color: AppConstants.primaryColor,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ChallengeStatsCard(),
              ),
            ),

          // Content with padding
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Challenges Section
                _buildSectionHeader('Active Challenges', Icons.timer),
                const SizedBox(height: AppConstants.smallPadding),
                Consumer<ChallengeProvider>(
                  builder: (context, challengeProvider, child) {
                    final activeChallenges = challengeProvider.activeChallenges;

                    if (activeChallenges.isEmpty) {
                      return _buildEmptyActiveState();
                    }

                    return Column(
                      children: activeChallenges.map((userChallenge) {
                        final challenge = challengeProvider
                            .getChallengeById(userChallenge.challengeId);
                        if (challenge == null) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.smallPadding),
                          child: ChallengeCard(
                            challenge: challenge,
                            userChallenge: userChallenge,
                            isEnrolled: true,
                            progress: challengeProvider
                                .getChallengeProgress(challenge.id),
                            onToggle: () =>
                                _toggleChallengeEnrollment(challenge.id),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Badges Section
                _buildSectionHeader('Earned Badges', Icons.emoji_events),
                const SizedBox(height: AppConstants.smallPadding),
                const BadgesSection(),

                const SizedBox(height: AppConstants.largePadding),

                // Recent Completions
                _buildSectionHeader('Recent Completions', Icons.check_circle),
                const SizedBox(height: AppConstants.smallPadding),
                _buildRecentCompletions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeListTab(List<Challenge> challenges) {
    if (challenges.isEmpty) {
      return _buildEmptyChallengesState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];

        return Consumer<ChallengeProvider>(
          builder: (context, challengeProvider, child) {
            final isEnrolled =
                challengeProvider.isEnrolledInChallenge(challenge.id);
            final userChallenge = challengeProvider.enrolledChallenges
                .where((uc) => uc.challengeId == challenge.id)
                .firstOrNull;
            final progress =
                challengeProvider.getChallengeProgress(challenge.id);

            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppConstants.defaultPadding),
              child: ChallengeCard(
                challenge: challenge,
                userChallenge: userChallenge,
                isEnrolled: isEnrolled,
                progress: progress,
                onToggle: () => _toggleChallengeEnrollment(challenge.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
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
    );
  }

  Widget _buildEmptyActiveState() {
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
            Icons.flag_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'No active challenges',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Tap on Daily, Weekly, or Monthly tabs to enroll in challenges!',
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

  Widget _buildEmptyChallengesState() {
    return Center(
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
            'No challenges available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Check back later for new challenges!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCompletions() {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, child) {
        final completedChallenges =
            challengeProvider.completedChallenges.take(3).toList();

        if (completedChallenges.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Text(
              'Complete some challenges to see them here!',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          children: completedChallenges.map((userChallenge) {
            final challenge =
                challengeProvider.getChallengeById(userChallenge.challengeId);
            if (challenge == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                    color: AppConstants.successColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppConstants.successColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${challenge.pointsReward} points earned',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    challenge.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _toggleChallengeEnrollment(String challengeId) {
    final challengeProvider = context.read<ChallengeProvider>();

    if (challengeProvider.isEnrolledInChallenge(challengeId)) {
      _showUnenrollDialog(challengeId);
    } else {
      challengeProvider.enrollInChallenge(challengeId);
      _showEnrollmentSuccess(challengeId);
    }
  }

  void _showUnenrollDialog(String challengeId) {
    final challengeProvider = context.read<ChallengeProvider>();
    final challenge = challengeProvider.getChallengeById(challengeId);

    if (challenge == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Challenge'),
        content: Text(
          'Are you sure you want to leave "${challenge.title}"? '
          'Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              challengeProvider.unenrollFromChallenge(challengeId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Left challenge: ${challenge.title}'),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            },
            style:
                TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showEnrollmentSuccess(String challengeId) {
    final challengeProvider = context.read<ChallengeProvider>();
    final challenge = challengeProvider.getChallengeById(challengeId);

    if (challenge == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(challenge.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Enrolled in "${challenge.title}"! Good luck!'),
            ),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _tabController.animateTo(0); // Go to overview tab
          },
        ),
      ),
    );
  }
}

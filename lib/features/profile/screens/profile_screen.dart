import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/providers/challenge_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_service.dart';
import '../../gamification/widgets/badges_section.dart';
import '../../gamification/widgets/challenge_stats_card.dart';
import '../../gamification/widgets/challenge_card.dart';
import '../../../core/services/celebration_service.dart';
import '../widgets/settings_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _loadChallengeData();
    // Initialize celebration service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CelebrationService.initialize(this);
    });
  }

  @override
  void dispose() {
    CelebrationService.dispose();
    super.dispose();
  }

  Future<void> _loadChallengeData() async {
    // Set context for celebrations
    context.read<ChallengeProvider>().setContext(context);
    await context.read<ChallengeProvider>().refreshChallenges();
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
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: CelebrationHelper.buildWithCelebrations(
        child: RefreshIndicator(
          onRefresh: _loadChallengeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Challenge Statistics Header
                Container(
                  color: AppConstants.primaryColor,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ChallengeStatsCard(),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Challenges Section
                      _buildSectionHeader('Active Challenges', Icons.timer),
                      const SizedBox(height: AppConstants.smallPadding),
                      _buildActiveChallengesSection(),
                      
                      const SizedBox(height: AppConstants.largePadding),
                      
                      // Earned Badges Section
                      _buildSectionHeader('Earned Badges', Icons.emoji_events),
                      const SizedBox(height: AppConstants.smallPadding),
                      const BadgesSection(),
                      
                      const SizedBox(height: AppConstants.largePadding),
                      
                      // Available Challenges Section
                      _buildSectionHeader('Available Challenges', Icons.explore),
                      const SizedBox(height: AppConstants.smallPadding),
                      _buildAvailableChallengesSection(),
                      
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
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
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

  Widget _buildActiveChallengesSection() {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, child) {
        final activeChallenges = challengeProvider.activeChallenges;
        
        if (activeChallenges.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.flag_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No Active Challenges',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enroll in challenges to start earning points and badges!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => NavigationService.goToChallenges(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Browse Challenges'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: activeChallenges.map((userChallenge) {
            final challenge = challengeProvider.getChallengeById(userChallenge.challengeId);
            if (challenge == null) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ChallengeCard(
                challenge: challenge,
                isEnrolled: true,
                progress: challengeProvider.getChallengeProgress(challenge.id),
                onToggle: () => _toggleChallengeEnrollment(challenge.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAvailableChallengesSection() {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, child) {
        final availableChallenges = challengeProvider.availableChallenges
            .where((challenge) => !challengeProvider.isEnrolledInChallenge(challenge.id))
            .take(3)
            .toList();
            
        if (availableChallenges.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.done_all, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'All Challenges Enrolled!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re enrolled in all available challenges. Keep up the great work!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ...availableChallenges.map((challenge) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ChallengeCard(
                challenge: challenge,
                isEnrolled: false,
                progress: 0.0,
                onToggle: () => _toggleChallengeEnrollment(challenge.id),
              ),
            )),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => NavigationService.goToChallenges(),
              child: const Text('View All Challenges'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentCompletions() {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, child) {
        final completedChallenges = challengeProvider.completedChallenges
            .take(3)
            .toList();
            
        if (completedChallenges.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.pending_actions, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No Completions Yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete challenges to see your achievements here!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: completedChallenges.map((userChallenge) {
            final challenge = challengeProvider.getChallengeById(userChallenge.challengeId);
            if (challenge == null) return const SizedBox.shrink();
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppConstants.successColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completed ${_formatCompletionDate(userChallenge.completedDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '+${challenge.pointsReward} pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatCompletionDate(DateTime? date) {
    if (date == null) return 'recently';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
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
        title: const Text('Unenroll from Challenge?'),
        content: Text(
          'Are you sure you want to unenroll from "${challenge.title}"? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              challengeProvider.unenrollFromChallenge(challengeId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unenroll'),
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
          onPressed: () => NavigationService.goToChallenges(),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/challenge.dart' hide Badge;
import '../models/challenge.dart' as challenge_models;
import '../../core/services/challenge_service.dart';
import '../../core/services/database_service.dart';
import '../../core/services/celebration_service.dart';

class ChallengeProvider extends ChangeNotifier {
  List<Challenge> _availableChallenges = [];
  List<UserChallenge> _enrolledChallenges = [];
  List<challenge_models.Badge> _earnedBadges = [];
  Map<String, dynamic> _userStats = {};
  bool _isLoading = false;
  BuildContext? _context;

  List<Challenge> get availableChallenges => _availableChallenges;
  List<UserChallenge> get enrolledChallenges => _enrolledChallenges;
  List<challenge_models.Badge> get earnedBadges => _earnedBadges;
  Map<String, dynamic> get userStats => _userStats;
  bool get isLoading => _isLoading;

  List<Challenge> get dailyChallenges =>
      _availableChallenges.where((c) => c.type == ChallengeType.daily).toList();

  List<Challenge> get weeklyChallenges => _availableChallenges
      .where((c) => c.type == ChallengeType.weekly)
      .toList();

  List<Challenge> get monthlyChallenges => _availableChallenges
      .where((c) => c.type == ChallengeType.monthly)
      .toList();

  List<UserChallenge> get activeChallenges =>
      _enrolledChallenges.where((uc) => !uc.isCompleted).toList();

  List<UserChallenge> get completedChallenges =>
      _enrolledChallenges.where((uc) => uc.isCompleted).toList();

  int get totalPoints =>
      _earnedBadges.length * 50 +
      _enrolledChallenges.fold(0, (sum, uc) {
        if (uc.isCompleted) {
          final challenge = getChallengeById(uc.challengeId);
          return sum + (challenge?.pointsReward ?? 0);
        }
        return sum;
      });

  ChallengeProvider() {
    _loadChallenges();
  }

  /// Set the build context for celebrations
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> _loadChallenges() async {
    _isLoading = true;
    notifyListeners();

    try {
      _availableChallenges = ChallengeService.getAllChallenges();
      _enrolledChallenges = await _loadUserChallenges();
      _earnedBadges = await _loadEarnedBadges();
      await _updateUserStats();
      await _checkChallengeCompletions();
    } catch (e) {
      debugPrint('Error loading challenges: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<UserChallenge>> _loadUserChallenges() async {
    // Load from database - for now return empty list
    // TODO: Implement database storage for user challenges
    return [];
  }

  Future<List<challenge_models.Badge>> _loadEarnedBadges() async {
    // Load from database - for now return empty list
    // TODO: Implement database storage for badges
    return [];
  }

  Future<void> _updateUserStats() async {
    try {
      final userData = DatabaseService.getCurrentUser();
      final expenses = DatabaseService.getAllExpenses();
      final goals = DatabaseService.getAllGoals();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Today's stats
      final todayExpenses =
          expenses.where((e) => _isSameDay(e.dateTime, now)).toList();
      final todaySpending = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);
      final todayCategorySpending = <String, double>{};

      for (final expense in todayExpenses) {
        todayCategorySpending[expense.category] =
            (todayCategorySpending[expense.category] ?? 0.0) + expense.amount;
      }

      // Weekly stats
      final weekExpenses =
          expenses.where((e) => e.dateTime.isAfter(startOfWeek)).toList();
      final weeklyGoalSavings = goals.fold(0.0, (sum, goal) {
        // Calculate goal contributions this week
        // This is simplified - in a real app, you'd track individual contributions
        return sum +
            (goal.currentAmount * 0.1); // Assume 10% was added this week
      });

      // Monthly stats
      final monthExpenses =
          expenses.where((e) => e.dateTime.isAfter(startOfMonth)).toList();
      final monthlySpending =
          monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
      final monthlySavings =
          goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
      final completedGoalsThisMonth = goals
          .where((g) =>
              g.isCompleted &&
              g.completedDate != null &&
              g.completedDate!.isAfter(startOfMonth))
          .length;

      // Calculate expense streak
      int currentStreak = 0;
      DateTime checkDate = today;

      for (int i = 0; i < 365; i++) {
        final dayExpenses =
            expenses.where((e) => _isSameDay(e.dateTime, checkDate)).toList();
        if (dayExpenses.isNotEmpty) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      _userStats = {
        'lastAppOpen': DateTime.now(),
        'todayExpenseCount': todayExpenses.length,
        'todaySpending': todaySpending,
        'todayCategorySpending': todayCategorySpending,
        'todayGoalContributions': 0.0, // Would be tracked separately
        'weeklyDetailedExpenses': weekExpenses.length,
        'weeklyGoalSavings': weeklyGoalSavings,
        'currentExpenseStreak': currentStreak,
        'monthlySpending': monthlySpending,
        'monthlyBudget': userData?.monthlyBudget ?? 0.0,
        'monthlyIncome': userData?.monthlyIncome ?? 0.0,
        'monthlySavings': monthlySavings,
        'completedGoalsThisMonth': completedGoalsThisMonth,
        'monthlyCategorizedExpenses': monthExpenses.length,
        'budgetDaysThisWeek': 0, // Would need daily budget tracking
        'categoriesUnderBudgetThisWeek': 0, // Would need category budgets
      };
    } catch (e) {
      debugPrint('Error updating user stats: $e');
    }
  }

  Future<void> _checkChallengeCompletions() async {
    bool hasNewCompletions = false;

    for (final userChallenge in _enrolledChallenges) {
      if (userChallenge.isCompleted) continue;

      final challenge = getChallengeById(userChallenge.challengeId);
      if (challenge == null) continue;

      final isCompleted = ChallengeService.checkChallengeCompletion(
          challenge, userChallenge, _userStats);

      if (isCompleted) {
        userChallenge.isCompleted = true;
        userChallenge.completedDate = DateTime.now();

        // Award badge if applicable
        String? badgeName;
        if (challenge.badgeReward != null) {
          await _awardBadge(challenge.badgeReward!);
          final badge =
              ChallengeService.getAvailableBadges()[challenge.badgeReward!];
          badgeName = badge?.name;
        }

        // Update streak if it's a daily challenge
        if (challenge.type == ChallengeType.daily) {
          await _updateDailyStreak(userChallenge);
        }

        // Celebrate the challenge completion
        if (_context != null) {
          CelebrationService.celebrateChallengeComplete(
            _context!,
            challengeTitle: challenge.title,
            pointsEarned: challenge.pointsReward,
            badgeName: badgeName,
          );
        }

        hasNewCompletions = true;
        debugPrint('✅ Challenge completed: ${challenge.title}');
      }
    }

    if (hasNewCompletions) {
      await _saveChallengeProgress();
      notifyListeners();
    }
  }

  Future<void> enrollInChallenge(String challengeId) async {
    if (isEnrolledInChallenge(challengeId)) return;

    final userChallenge = UserChallenge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      challengeId: challengeId,
      enrolledDate: DateTime.now(),
    );

    _enrolledChallenges.add(userChallenge);
    await _saveChallengeProgress();
    await _checkChallengeCompletions();
    notifyListeners();
  }

  Future<void> unenrollFromChallenge(String challengeId) async {
    _enrolledChallenges.removeWhere((uc) => uc.challengeId == challengeId);
    await _saveChallengeProgress();
    notifyListeners();
  }

  bool isEnrolledInChallenge(String challengeId) {
    return _enrolledChallenges.any((uc) => uc.challengeId == challengeId);
  }

  Challenge? getChallengeById(String challengeId) {
    try {
      return _availableChallenges.firstWhere((c) => c.id == challengeId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _awardBadge(String badgeId) async {
    if (_earnedBadges.any((b) => b.id == badgeId)) return;

    final availableBadges = ChallengeService.getAvailableBadges();
    final badge = availableBadges[badgeId];

    if (badge != null) {
      final earnedBadge = challenge_models.Badge(
        id: badge.id,
        name: badge.name,
        description: badge.description,
        icon: badge.icon,
        color: badge.color,
        earnedDate: DateTime.now(),
      );

      _earnedBadges.add(earnedBadge);
      await _saveEarnedBadges();

      // Celebrate the badge earning
      if (_context != null) {
        CelebrationService.celebrateBadgeEarned(
          _context!,
          badgeName: badge.name,
          badgeIcon: badge.icon,
        );
      }

      debugPrint('🏆 Badge earned: ${badge.name}');
    }
  }

  Future<void> _updateDailyStreak(UserChallenge userChallenge) async {
    // Update user's overall streak if they completed a daily challenge
    final userData = DatabaseService.getCurrentUser();
    if (userData != null) {
      final now = DateTime.now();
      final lastActive = userData.lastActiveDate;

      if (_isSameDay(lastActive, now.subtract(const Duration(days: 1)))) {
        // Consecutive day - increment streak
        userData.currentStreak += 1;
      } else if (!_isSameDay(lastActive, now)) {
        // New streak or broken streak
        userData.currentStreak = 1;
      }

      if (userData.currentStreak > userData.longestStreak) {
        userData.longestStreak = userData.currentStreak;
      }

      // Celebrate streak milestones
      if (_context != null && _shouldCelebrateStreak(userData.currentStreak)) {
        CelebrationService.celebrateStreakMilestone(
          _context!,
          streakDays: userData.currentStreak,
        );
      }

      userData.lastActiveDate = now;
      await DatabaseService.saveUserData(userData);
    }
  }

  Future<void> _saveChallengeProgress() async {
    // TODO: Implement database storage for user challenges
    // For now, we'll use temporary in-memory storage
    debugPrint('💾 Saving challenge progress...');
  }

  Future<void> _saveEarnedBadges() async {
    // TODO: Implement database storage for badges
    // For now, we'll use temporary in-memory storage
    debugPrint('💾 Saving earned badges...');
  }

  Future<void> refreshChallenges() async {
    await _updateUserStats();
    await _checkChallengeCompletions();
  }

  // Trigger challenge checks when user performs actions
  Future<void> onExpenseAdded() async {
    await _updateUserStats();
    await _checkChallengeCompletions();
  }

  Future<void> onGoalContribution(double amount) async {
    _userStats['todayGoalContributions'] =
        (_userStats['todayGoalContributions'] as double? ?? 0.0) + amount;
    await _checkChallengeCompletions();
  }

  Future<void> onAppOpened() async {
    _userStats['lastAppOpen'] = DateTime.now();
    await _checkChallengeCompletions();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if streak milestone should be celebrated
  bool _shouldCelebrateStreak(int streak) {
    // Celebrate specific milestones
    if (streak == 7 || streak == 30 || streak == 50 || streak == 100) {
      return true;
    }
    // Celebrate every 25 days after 100
    if (streak > 100 && streak % 25 == 0) {
      return true;
    }
    return false;
  }

  // Get progress percentage for a specific challenge
  double getChallengeProgress(String challengeId) {
    final userChallenge = _enrolledChallenges
        .where((uc) => uc.challengeId == challengeId)
        .firstOrNull;

    if (userChallenge == null) return 0.0;
    if (userChallenge.isCompleted) return 100.0;

    final challenge = getChallengeById(challengeId);
    if (challenge == null) return 0.0;

    // Calculate progress based on challenge requirements
    final requirements = challenge.requirements;
    final action = requirements['action'] as String;

    switch (action) {
      case 'spend_limit':
        final limit = requirements['amount'] as double;
        final todaySpending = _userStats['todaySpending'] as double? ?? 0.0;
        if (todaySpending <= limit) return 100.0;
        return ((limit / todaySpending) * 100).clamp(0.0, 100.0);

      case 'log_expense':
        final target = requirements['count'] as int;
        final current = _userStats['todayExpenseCount'] as int? ?? 0;
        return ((current / target) * 100).clamp(0.0, 100.0);

      case 'weekly_goal_savings':
        final target = requirements['amount'] as double;
        final current = _userStats['weeklyGoalSavings'] as double? ?? 0.0;
        return ((current / target) * 100).clamp(0.0, 100.0);

      default:
        return 0.0;
    }
  }
}

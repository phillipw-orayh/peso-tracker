import 'package:flutter/foundation.dart';
import '../models/user_data.dart';
import '../../core/services/database_service.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final int points;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.points,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final DateTime earnedDate;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.earnedDate,
  });
}

class GamificationProvider extends ChangeNotifier {
  UserData? _userData;
  List<Challenge> _activeChallenges = [];
  List<Badge> _earnedBadges = [];
  bool _isLoading = false;

  UserData? get userData => _userData;
  List<Challenge> get activeChallenges => _activeChallenges;
  List<Badge> get earnedBadges => _earnedBadges;
  bool get isLoading => _isLoading;

  int get currentStreak => _userData?.currentStreak ?? 0;
  int get longestStreak => _userData?.longestStreak ?? 0;
  int get totalPoints => _userData?.totalPoints ?? 0;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userData = DatabaseService.getCurrentUser();
      if (_userData != null) {
        _updateStreak();
        _loadChallenges();
        _loadBadges();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData(UserData userData) async {
    try {
      await DatabaseService.saveUserData(userData);
      _userData = userData;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> addPoints(int points) async {
    if (_userData != null) {
      final updatedUser = _userData!.copyWith(
        totalPoints: _userData!.totalPoints + points,
      );
      await updateUserData(updatedUser);
    }
  }

  Future<void> updateStreak() async {
    if (_userData != null) {
      final now = DateTime.now();
      final lastActive = _userData!.lastActiveDate;
      final daysDiff = now.difference(lastActive).inDays;

      int newStreak = _userData!.currentStreak;
      
      if (daysDiff == 0) {
        return;
      } else if (daysDiff == 1) {
        newStreak += 1;
      } else {
        newStreak = 1;
      }

      final updatedUser = _userData!.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > _userData!.longestStreak 
            ? newStreak 
            : _userData!.longestStreak,
        lastActiveDate: now,
      );

      await updateUserData(updatedUser);
      
      if (newStreak % 7 == 0) {
        await addPoints(50);
        await _checkStreakBadges(newStreak);
      }
    }
  }

  Future<void> completeChallenge(String challengeId) async {
    final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1 && _userData != null) {
      final challenge = _activeChallenges[challengeIndex];
      
      if (!challenge.isCompleted) {
        await addPoints(challenge.points);
        
        final completedChallenges = List<String>.from(_userData!.completedChallenges)
          ..add(challengeId);
        
        final updatedUser = _userData!.copyWith(
          completedChallenges: completedChallenges,
        );
        
        await updateUserData(updatedUser);
        
        _activeChallenges[challengeIndex] = Challenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          points: challenge.points,
          startDate: challenge.startDate,
          endDate: challenge.endDate,
          isCompleted: true,
        );
        
        notifyListeners();
        
        await _checkChallengeBadges();
      }
    }
  }

  void _updateStreak() {
    if (_userData != null) {
      final now = DateTime.now();
      final lastActive = _userData!.lastActiveDate;
      final daysDiff = now.difference(lastActive).inDays;
      
      if (daysDiff > 1) {
        final updatedUser = _userData!.copyWith(currentStreak: 0);
        DatabaseService.saveUserData(updatedUser);
        _userData = updatedUser;
      }
    }
  }

  void _loadChallenges() {
    final now = DateTime.now();
    _activeChallenges = [
      Challenge(
        id: 'tipid_tuesday',
        title: 'Tipid Tuesday',
        description: 'Spend less than ₱200 today',
        type: 'daily',
        points: 10,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
      ),
      Challenge(
        id: 'no_kape_challenge',
        title: 'No Kape Challenge',
        description: 'Skip coffee shop visits today',
        type: 'daily',
        points: 15,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
      ),
      Challenge(
        id: 'week_saver',
        title: 'Week-long Saver',
        description: 'Meet weekly budget 5 out of 7 days',
        type: 'weekly',
        points: 50,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
      ),
    ];
  }

  void _loadBadges() {
    if (_userData?.earnedBadges != null) {
      _earnedBadges = _userData!.earnedBadges.map((badgeId) {
        return Badge(
          id: badgeId,
          name: _getBadgeName(badgeId),
          description: _getBadgeDescription(badgeId),
          iconPath: 'assets/icons/badge_$badgeId.png',
          earnedDate: DateTime.now(),
        );
      }).toList();
    }
  }

  String _getBadgeName(String badgeId) {
    switch (badgeId) {
      case 'masinop_pinoy':
        return 'Masinop na Pinoy';
      case 'ipon_master':
        return 'Ipon Master';
      case 'budget_warrior':
        return 'Budget Warrior';
      case 'goal_crusher':
        return 'Goal Crusher';
      default:
        return 'Unknown Badge';
    }
  }

  String _getBadgeDescription(String badgeId) {
    switch (badgeId) {
      case 'masinop_pinoy':
        return 'Complete 30 days of budget tracking';
      case 'ipon_master':
        return 'Save ₱10,000 in total';
      case 'budget_warrior':
        return 'Stay under budget for 3 months';
      case 'goal_crusher':
        return 'Complete 5 savings goals';
      default:
        return 'Achievement unlocked!';
    }
  }

  Future<void> _checkStreakBadges(int streak) async {
    if (_userData != null) {
      final badges = List<String>.from(_userData!.earnedBadges);
      
      if (streak >= 30 && !badges.contains('masinop_pinoy')) {
        badges.add('masinop_pinoy');
        final updatedUser = _userData!.copyWith(earnedBadges: badges);
        await updateUserData(updatedUser);
      }
    }
  }

  Future<void> _checkChallengeBadges() async {
    if (_userData != null) {
      final completedCount = _userData!.completedChallenges.length;
      final badges = List<String>.from(_userData!.earnedBadges);
      
      if (completedCount >= 10 && !badges.contains('budget_warrior')) {
        badges.add('budget_warrior');
        final updatedUser = _userData!.copyWith(earnedBadges: badges);
        await updateUserData(updatedUser);
      }
    }
  }

  // User Management Methods
  UserData? get currentUser => _userData;
  
  int get currentLevel => (_userData?.totalPoints ?? 0) ~/ 100 + 1;

  Future<void> switchUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = DatabaseService.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      await DatabaseService.setCurrentUser(userId);
      _userData = user;
      
      // Reload user-specific data
      _updateStreak();
      _loadChallenges();
      _loadBadges();
      
      debugPrint('✅ Switched to user: ${user.name}');
    } catch (e) {
      debugPrint('❌ Error switching user: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCurrentUser() async {
    try {
      _userData = null;
      _activeChallenges.clear();
      _earnedBadges.clear();
      
      await DatabaseService.setCurrentUser('');
      notifyListeners();
      
      debugPrint('✅ Current user cleared');
    } catch (e) {
      debugPrint('❌ Error clearing current user: $e');
      rethrow;
    }
  }

  Future<void> initializeUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUserId = DatabaseService.getCurrentUserId();
      if (currentUserId != null && currentUserId.isNotEmpty) {
        final user = DatabaseService.getUserById(currentUserId);
        if (user != null) {
          _userData = user;
          _updateStreak();
          _loadChallenges();
          _loadBadges();
        }
      }
    } catch (e) {
      debugPrint('❌ Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
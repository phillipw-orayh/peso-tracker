import 'package:hive/hive.dart';

part 'user_data.g.dart';

@HiveType(typeId: 3)
class UserData extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String email;
  
  @HiveField(3)
  double monthlyIncome;
  
  @HiveField(4)
  double monthlyBudget;
  
  @HiveField(5)
  String preferredLanguage;
  
  @HiveField(6)
  int currentStreak;
  
  @HiveField(7)
  int longestStreak;
  
  @HiveField(8)
  DateTime lastActiveDate;
  
  @HiveField(9)
  List<String> completedChallenges;
  
  @HiveField(10)
  List<String> earnedBadges;
  
  @HiveField(11)
  int totalPoints;
  
  @HiveField(12)
  Map<String, dynamic> settings;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.monthlyIncome = 0.0,
    this.monthlyBudget = 0.0,
    this.preferredLanguage = 'tl',
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActiveDate,
    this.completedChallenges = const [],
    this.earnedBadges = const [],
    this.totalPoints = 0,
    this.settings = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'monthlyIncome': monthlyIncome,
      'monthlyBudget': monthlyBudget,
      'preferredLanguage': preferredLanguage,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate.millisecondsSinceEpoch,
      'completedChallenges': completedChallenges,
      'earnedBadges': earnedBadges,
      'totalPoints': totalPoints,
      'settings': settings,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      monthlyIncome: map['monthlyIncome']?.toDouble() ?? 0.0,
      monthlyBudget: map['monthlyBudget']?.toDouble() ?? 0.0,
      preferredLanguage: map['preferredLanguage'] ?? 'tl',
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastActiveDate: DateTime.fromMillisecondsSinceEpoch(
        map['lastActiveDate'] ?? DateTime.now().millisecondsSinceEpoch
      ),
      completedChallenges: List<String>.from(map['completedChallenges'] ?? []),
      earnedBadges: List<String>.from(map['earnedBadges'] ?? []),
      totalPoints: map['totalPoints'] ?? 0,
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  UserData copyWith({
    String? id,
    String? name,
    String? email,
    double? monthlyIncome,
    double? monthlyBudget,
    String? preferredLanguage,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    List<String>? completedChallenges,
    List<String>? earnedBadges,
    int? totalPoints,
    Map<String, dynamic>? settings,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      totalPoints: totalPoints ?? this.totalPoints,
      settings: settings ?? this.settings,
    );
  }
}
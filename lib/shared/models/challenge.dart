import 'package:hive/hive.dart';

part 'challenge.g.dart';

@HiveType(typeId: 4)
enum ChallengeType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly
}

@HiveType(typeId: 5)
enum ChallengeCategory {
  @HiveField(0)
  spending,
  @HiveField(1)
  savings,
  @HiveField(2)
  goals,
  @HiveField(3)
  habits,
  @HiveField(4)
  social
}

@HiveType(typeId: 6)
class Challenge extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  ChallengeType type;
  
  @HiveField(4)
  ChallengeCategory category;
  
  @HiveField(5)
  Map<String, dynamic> requirements;
  
  @HiveField(6)
  int pointsReward;
  
  @HiveField(7)
  String? badgeReward;
  
  @HiveField(8)
  String icon;
  
  @HiveField(9)
  bool isActive;
  
  @HiveField(10)
  DateTime? activatedDate;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.requirements,
    this.pointsReward = 10,
    this.badgeReward,
    this.icon = '🎯',
    this.isActive = true,
    this.activatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'category': category.index,
      'requirements': requirements,
      'pointsReward': pointsReward,
      'badgeReward': badgeReward,
      'icon': icon,
      'isActive': isActive,
      'activatedDate': activatedDate?.millisecondsSinceEpoch,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ChallengeType.values[map['type'] ?? 0],
      category: ChallengeCategory.values[map['category'] ?? 0],
      requirements: Map<String, dynamic>.from(map['requirements'] ?? {}),
      pointsReward: map['pointsReward'] ?? 10,
      badgeReward: map['badgeReward'],
      icon: map['icon'] ?? '🎯',
      isActive: map['isActive'] ?? true,
      activatedDate: map['activatedDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['activatedDate'])
          : null,
    );
  }
}

@HiveType(typeId: 7)
class UserChallenge extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String challengeId;
  
  @HiveField(2)
  DateTime enrolledDate;
  
  @HiveField(3)
  bool isCompleted;
  
  @HiveField(4)
  DateTime? completedDate;
  
  @HiveField(5)
  Map<String, dynamic> progress;
  
  @HiveField(6)
  int currentStreak;
  
  @HiveField(7)
  DateTime? lastActivityDate;

  UserChallenge({
    required this.id,
    required this.challengeId,
    required this.enrolledDate,
    this.isCompleted = false,
    this.completedDate,
    this.progress = const {},
    this.currentStreak = 0,
    this.lastActivityDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'challengeId': challengeId,
      'enrolledDate': enrolledDate.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.millisecondsSinceEpoch,
      'progress': progress,
      'currentStreak': currentStreak,
      'lastActivityDate': lastActivityDate?.millisecondsSinceEpoch,
    };
  }

  factory UserChallenge.fromMap(Map<String, dynamic> map) {
    return UserChallenge(
      id: map['id'] ?? '',
      challengeId: map['challengeId'] ?? '',
      enrolledDate: DateTime.fromMillisecondsSinceEpoch(map['enrolledDate'] ?? 0),
      isCompleted: map['isCompleted'] ?? false,
      completedDate: map['completedDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'])
          : null,
      progress: Map<String, dynamic>.from(map['progress'] ?? {}),
      currentStreak: map['currentStreak'] ?? 0,
      lastActivityDate: map['lastActivityDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastActivityDate'])
          : null,
    );
  }
}

@HiveType(typeId: 8)
class Badge extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  String icon;
  
  @HiveField(4)
  String color;
  
  @HiveField(5)
  DateTime earnedDate;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.color = '#FFD700',
    required this.earnedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'earnedDate': earnedDate.millisecondsSinceEpoch,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🏆',
      color: map['color'] ?? '#FFD700',
      earnedDate: DateTime.fromMillisecondsSinceEpoch(map['earnedDate'] ?? 0),
    );
  }
}
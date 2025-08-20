import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 1)
enum GoalType {
  @HiveField(0)
  shortTerm,
  @HiveField(1)
  mediumTerm,
  @HiveField(2)
  longTerm
}

@HiveType(typeId: 2)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  double targetAmount;
  
  @HiveField(4)
  double currentAmount;
  
  @HiveField(5)
  DateTime createdDate;
  
  @HiveField(6)
  DateTime targetDate;
  
  @HiveField(7)
  GoalType type;
  
  @HiveField(8)
  String? iconPath;
  
  @HiveField(9)
  bool isCompleted;
  
  @HiveField(10)
  DateTime? completedDate;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdDate,
    required this.targetDate,
    required this.type,
    this.iconPath,
    this.isCompleted = false,
    this.completedDate,
  });

  // Alias for currentAmount to match screen usage
  double get savedAmount => currentAmount;
  set savedAmount(double value) => currentAmount = value;

  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0, targetAmount);
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return targetDate.difference(now).inDays;
  }

  double get dailySavingsNeeded {
    if (daysRemaining <= 0) return remainingAmount;
    return remainingAmount / daysRemaining;
  }

  SavingsGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? savedAmount,
    DateTime? createdDate,
    DateTime? targetDate,
    GoalType? type,
    String? iconPath,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: savedAmount ?? currentAmount,
      createdDate: createdDate ?? this.createdDate,
      targetDate: targetDate ?? this.targetDate,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'type': type.index,
      'iconPath': iconPath,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.millisecondsSinceEpoch,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      targetAmount: map['targetAmount']?.toDouble() ?? 0.0,
      currentAmount: map['currentAmount']?.toDouble() ?? 0.0,
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate'] ?? 0),
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate'] ?? 0),
      type: GoalType.values[map['type'] ?? 0],
      iconPath: map['iconPath'],
      isCompleted: map['isCompleted'] ?? false,
      completedDate: map['completedDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'])
          : null,
    );
  }
}
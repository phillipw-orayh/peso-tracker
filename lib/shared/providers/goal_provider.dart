import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../../core/services/database_service.dart';
import '../../core/services/celebration_service.dart';

class GoalProvider extends ChangeNotifier {
  List<SavingsGoal> _goals = [];
  bool _isLoading = false;
  BuildContext? _context;

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;

  List<SavingsGoal> get activeGoals => 
      _goals.where((goal) => !goal.isCompleted).toList();

  List<SavingsGoal> get completedGoals => 
      _goals.where((goal) => goal.isCompleted).toList();

  double get totalSavingsGoalAmount {
    return activeGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
  }

  double get totalCurrentSavings {
    return activeGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  }

  double get totalSavingsProgress {
    if (totalSavingsGoalAmount == 0) return 0;
    return (totalCurrentSavings / totalSavingsGoalAmount * 100).clamp(0, 100);
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = DatabaseService.getAllGoals();
      _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(SavingsGoal goal) async {
    try {
      await DatabaseService.addGoal(goal);
      _goals.add(goal);
      _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding goal: $e');
      rethrow;
    }
  }

  /// Set the build context for celebrations
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    try {
      final oldGoal = _goals.firstWhere((g) => g.id == goal.id);
      final wasCompleted = oldGoal.isCompleted;
      
      await DatabaseService.updateGoal(goal);
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        
        // Celebrate goal achievement
        if (!wasCompleted && goal.isCompleted && _context != null) {
          CelebrationService.celebrateGoalAchieved(
            _context!,
            goalTitle: goal.title,
            amount: goal.targetAmount,
          );
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating goal: $e');
      rethrow;
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await DatabaseService.deleteGoal(id);
      _goals.removeWhere((goal) => goal.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
      rethrow;
    }
  }

  Future<void> addSavings(String goalId, double amount) async {
    await addToGoal(goalId, amount);
  }

  Future<void> addToGoal(String goalId, double amount) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final updatedGoal = SavingsGoal(
          id: goal.id,
          title: goal.title,
          description: goal.description,
          targetAmount: goal.targetAmount,
          currentAmount: goal.currentAmount + amount,
          createdDate: goal.createdDate,
          targetDate: goal.targetDate,
          type: goal.type,
          iconPath: goal.iconPath,
          isCompleted: (goal.currentAmount + amount) >= goal.targetAmount,
          completedDate: (goal.currentAmount + amount) >= goal.targetAmount
              ? DateTime.now()
              : null,
        );
        
        await updateGoal(updatedGoal);
      }
    } catch (e) {
      debugPrint('Error adding to goal: $e');
      rethrow;
    }
  }

  Future<void> completeGoal(String goalId) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final completedGoal = SavingsGoal(
          id: goal.id,
          title: goal.title,
          description: goal.description,
          targetAmount: goal.targetAmount,
          currentAmount: goal.targetAmount,
          createdDate: goal.createdDate,
          targetDate: goal.targetDate,
          type: goal.type,
          iconPath: goal.iconPath,
          isCompleted: true,
          completedDate: DateTime.now(),
        );
        
        await updateGoal(completedGoal);
      }
    } catch (e) {
      debugPrint('Error completing goal: $e');
      rethrow;
    }
  }
}
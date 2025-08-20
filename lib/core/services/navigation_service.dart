import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/expense/screens/expense_list_screen.dart';
import '../../features/expense/screens/add_expense_screen.dart';
import '../../features/goals/screens/goals_screen.dart';
import '../../features/goals/screens/add_goal_screen.dart';
import '../../features/goals/screens/edit_goal_screen.dart';
import '../../features/gamification/screens/challenges_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const ExpenseListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-expense',
            builder: (context, state) => const AddExpenseScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/goals',
        name: 'goals',
        builder: (context, state) => const GoalsScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-goal',
            builder: (context, state) => const AddGoalScreen(),
          ),
          GoRoute(
            path: 'edit/:goalId',
            name: 'edit-goal',
            builder: (context, state) => EditGoalScreen(
              goalId: state.pathParameters['goalId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/challenges',
        name: 'challenges',
        builder: (context, state) => const ChallengesScreen(),
      ),
    ],
  );

  static void goToHome() {
    router.go('/home');
  }

  static void goToExpenses() {
    router.go('/expenses');
  }

  static void goToAddExpense() {
    router.go('/expenses/add');
  }

  static void goToGoals() {
    router.go('/goals');
  }

  static void goToAddGoal() {
    router.go('/goals/add');
  }

  static void goToEditGoal(String goalId) {
    router.go('/goals/edit/$goalId');
  }

  static void goToProfile() {
    router.go('/profile');
  }

  static void goToChallenges() {
    router.go('/challenges');
  }

  static void pop() {
    if (router.canPop()) {
      router.pop();
    }
  }
}

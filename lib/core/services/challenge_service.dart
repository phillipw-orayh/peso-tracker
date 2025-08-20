import '../../shared/models/challenge.dart';

class ChallengeService {
  static List<Challenge> getAllChallenges() {
    return [
      // Daily Challenges
      Challenge(
        id: 'daily_app_open',
        title: 'Daily Check-in',
        description: 'Open the app and check your financial status',
        type: ChallengeType.daily,
        category: ChallengeCategory.habits,
        requirements: {'action': 'open_app'},
        pointsReward: 5,
        icon: '📱',
      ),
      Challenge(
        id: 'daily_expense_log',
        title: 'Expense Logger',
        description: 'Log at least one expense today',
        type: ChallengeType.daily,
        category: ChallengeCategory.habits,
        requirements: {'action': 'log_expense', 'count': 1},
        pointsReward: 10,
        icon: '📝',
      ),
      Challenge(
        id: 'tipid_tuesday',
        title: 'Tipid Tuesday',
        description: 'Spend less than ₱200 today',
        type: ChallengeType.daily,
        category: ChallengeCategory.spending,
        requirements: {'action': 'spend_limit', 'amount': 200.0},
        pointsReward: 20,
        icon: '💰',
      ),
      Challenge(
        id: 'no_kape_challenge',
        title: 'No Kape Challenge',
        description: 'Skip coffee shop visits today',
        type: ChallengeType.daily,
        category: ChallengeCategory.spending,
        requirements: {'action': 'avoid_category', 'category': 'Entertainment'},
        pointsReward: 15,
        icon: '☕',
      ),
      Challenge(
        id: 'baon_lang',
        title: 'Baon Lang',
        description: 'Bring homemade lunch instead of buying',
        type: ChallengeType.daily,
        category: ChallengeCategory.spending,
        requirements: {'action': 'avoid_category', 'category': 'Pagkain'},
        pointsReward: 15,
        icon: '🍱',
      ),
      Challenge(
        id: 'jeepney_mode',
        title: 'Jeepney Mode',
        description: 'Use public transport instead of ride-sharing',
        type: ChallengeType.daily,
        category: ChallengeCategory.spending,
        requirements: {'action': 'transportation_limit', 'amount': 50.0},
        pointsReward: 10,
        icon: '🚌',
      ),
      Challenge(
        id: 'daily_goal_contribution',
        title: 'Goal Contributor',
        description: 'Add any amount to your savings goals',
        type: ChallengeType.daily,
        category: ChallengeCategory.savings,
        requirements: {'action': 'add_to_goal', 'amount': 0.01},
        pointsReward: 15,
        icon: '🎯',
      ),
      
      // Weekly Challenges
      Challenge(
        id: 'week_long_saver',
        title: 'Week-long Saver',
        description: 'Meet your daily budget 5 out of 7 days this week',
        type: ChallengeType.weekly,
        category: ChallengeCategory.spending,
        requirements: {'action': 'budget_days', 'target': 5, 'period': 7},
        pointsReward: 50,
        icon: '📅',
      ),
      Challenge(
        id: 'receipt_warrior',
        title: 'Receipt Warrior',
        description: 'Log every expense with detailed description',
        type: ChallengeType.weekly,
        category: ChallengeCategory.habits,
        requirements: {'action': 'detailed_expenses', 'count': 10},
        pointsReward: 30,
        icon: '🧾',
      ),
      Challenge(
        id: 'goal_getter_weekly',
        title: 'Goal Getter',
        description: 'Add ₱500 to any savings goal this week',
        type: ChallengeType.weekly,
        category: ChallengeCategory.savings,
        requirements: {'action': 'weekly_goal_savings', 'amount': 500.0},
        pointsReward: 40,
        icon: '💪',
      ),
      Challenge(
        id: 'consistent_tracker',
        title: 'Consistent Tracker',
        description: 'Log expenses for 7 consecutive days',
        type: ChallengeType.weekly,
        category: ChallengeCategory.habits,
        requirements: {'action': 'daily_log_streak', 'days': 7},
        pointsReward: 35,
        icon: '⭐',
      ),
      Challenge(
        id: 'category_master',
        title: 'Category Master',
        description: 'Stay within budget for at least 3 different categories',
        type: ChallengeType.weekly,
        category: ChallengeCategory.spending,
        requirements: {'action': 'category_budget', 'categories': 3},
        pointsReward: 45,
        icon: '📊',
      ),
      
      // Monthly Challenges
      Challenge(
        id: 'kuripot_royalty',
        title: 'Kuripot King/Queen',
        description: 'Stay under your monthly budget',
        type: ChallengeType.monthly,
        category: ChallengeCategory.spending,
        requirements: {'action': 'monthly_budget', 'stay_under': true},
        pointsReward: 100,
        badgeReward: 'kuripot_royalty',
        icon: '👑',
      ),
      Challenge(
        id: 'savings_superstar',
        title: 'Savings Superstar',
        description: 'Save 10% of your monthly income',
        type: ChallengeType.monthly,
        category: ChallengeCategory.savings,
        requirements: {'action': 'save_percentage', 'percentage': 10.0},
        pointsReward: 150,
        badgeReward: 'savings_superstar',
        icon: '⭐',
      ),
      Challenge(
        id: 'goal_achiever',
        title: 'Goal Achiever',
        description: 'Complete any savings goal this month',
        type: ChallengeType.monthly,
        category: ChallengeCategory.goals,
        requirements: {'action': 'complete_goal', 'count': 1},
        pointsReward: 200,
        badgeReward: 'goal_achiever',
        icon: '🏆',
      ),
      Challenge(
        id: 'financial_guru',
        title: 'Financial Guru',
        description: 'Maintain a 30-day expense tracking streak',
        type: ChallengeType.monthly,
        category: ChallengeCategory.habits,
        requirements: {'action': 'tracking_streak', 'days': 30},
        pointsReward: 120,
        badgeReward: 'financial_guru',
        icon: '🧠',
      ),
      Challenge(
        id: 'expense_analyst',
        title: 'Expense Analyst',
        description: 'Categorize at least 50 expenses this month',
        type: ChallengeType.monthly,
        category: ChallengeCategory.habits,
        requirements: {'action': 'categorized_expenses', 'count': 50},
        pointsReward: 80,
        icon: '📈',
      ),
    ];
  }
  
  static Map<String, Badge> getAvailableBadges() {
    return {
      'kuripot_royalty': Badge(
        id: 'kuripot_royalty',
        name: 'Kuripot Royalty',
        description: 'Mastered the art of staying under budget',
        icon: '👑',
        color: '#FFD700',
        earnedDate: DateTime.now(),
      ),
      'savings_superstar': Badge(
        id: 'savings_superstar',
        name: 'Ipon Master',
        description: 'Saved 10% of monthly income like a true Filipino',
        icon: '⭐',
        color: '#FF6B35',
        earnedDate: DateTime.now(),
      ),
      'goal_achiever': Badge(
        id: 'goal_achiever',
        name: 'Goal Crusher',
        description: 'Completed a savings goal against all odds',
        icon: '🏆',
        color: '#4CAF50',
        earnedDate: DateTime.now(),
      ),
      'financial_guru': Badge(
        id: 'financial_guru',
        name: 'Masinop na Pinoy',
        description: 'Consistently tracked expenses like a financial pro',
        icon: '🧠',
        color: '#2196F3',
        earnedDate: DateTime.now(),
      ),
      'streak_master': Badge(
        id: 'streak_master',
        name: 'Streak Master',
        description: 'Maintained financial discipline for weeks',
        icon: '🔥',
        color: '#FF5722',
        earnedDate: DateTime.now(),
      ),
      'budget_warrior': Badge(
        id: 'budget_warrior',
        name: 'Budget Warrior',
        description: 'Fought the good fight against overspending',
        icon: '⚔️',
        color: '#9C27B0',
        earnedDate: DateTime.now(),
      ),
    };
  }
  
  static bool checkChallengeCompletion(
    Challenge challenge, 
    UserChallenge userChallenge,
    Map<String, dynamic> userStats,
  ) {
    final requirements = challenge.requirements;
    final action = requirements['action'] as String;
    
    switch (action) {
      case 'open_app':
        return _checkDailyAppOpen(userStats);
      case 'log_expense':
        return _checkExpenseLogged(userStats, requirements);
      case 'spend_limit':
        return _checkSpendingLimit(userStats, requirements);
      case 'avoid_category':
        return _checkCategoryAvoidance(userStats, requirements);
      case 'transportation_limit':
        return _checkTransportationLimit(userStats, requirements);
      case 'add_to_goal':
        return _checkGoalContribution(userStats, requirements);
      case 'budget_days':
        return _checkBudgetDays(userStats, requirements);
      case 'detailed_expenses':
        return _checkDetailedExpenses(userStats, requirements);
      case 'weekly_goal_savings':
        return _checkWeeklyGoalSavings(userStats, requirements);
      case 'daily_log_streak':
        return _checkDailyLogStreak(userStats, requirements);
      case 'category_budget':
        return _checkCategoryBudget(userStats, requirements);
      case 'monthly_budget':
        return _checkMonthlyBudget(userStats, requirements);
      case 'save_percentage':
        return _checkSavePercentage(userStats, requirements);
      case 'complete_goal':
        return _checkCompleteGoal(userStats, requirements);
      case 'tracking_streak':
        return _checkTrackingStreak(userStats, requirements);
      case 'categorized_expenses':
        return _checkCategorizedExpenses(userStats, requirements);
      default:
        return false;
    }
  }
  
  // Challenge completion check methods
  static bool _checkDailyAppOpen(Map<String, dynamic> userStats) {
    final today = DateTime.now();
    final lastOpen = userStats['lastAppOpen'] as DateTime?;
    return lastOpen != null && _isSameDay(lastOpen, today);
  }
  
  static bool _checkExpenseLogged(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final count = requirements['count'] as int;
    final todayExpenses = userStats['todayExpenseCount'] as int? ?? 0;
    return todayExpenses >= count;
  }
  
  static bool _checkSpendingLimit(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final limit = requirements['amount'] as double;
    final todaySpending = userStats['todaySpending'] as double? ?? 0.0;
    return todaySpending <= limit;
  }
  
  static bool _checkCategoryAvoidance(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final category = requirements['category'] as String;
    final todayCategorySpending = userStats['todayCategorySpending'] as Map<String, double>? ?? {};
    return (todayCategorySpending[category] ?? 0.0) == 0.0;
  }
  
  static bool _checkTransportationLimit(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final limit = requirements['amount'] as double;
    final todayTransportSpending = userStats['todayCategorySpending'] as Map<String, double>? ?? {};
    return (todayTransportSpending['Transportasyon'] ?? 0.0) <= limit;
  }
  
  static bool _checkGoalContribution(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final minAmount = requirements['amount'] as double;
    final todayGoalContributions = userStats['todayGoalContributions'] as double? ?? 0.0;
    return todayGoalContributions >= minAmount;
  }
  
  static bool _checkBudgetDays(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final target = requirements['target'] as int;
    final budgetDaysThisWeek = userStats['budgetDaysThisWeek'] as int? ?? 0;
    return budgetDaysThisWeek >= target;
  }
  
  static bool _checkDetailedExpenses(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final count = requirements['count'] as int;
    final weeklyDetailedExpenses = userStats['weeklyDetailedExpenses'] as int? ?? 0;
    return weeklyDetailedExpenses >= count;
  }
  
  static bool _checkWeeklyGoalSavings(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final amount = requirements['amount'] as double;
    final weeklyGoalSavings = userStats['weeklyGoalSavings'] as double? ?? 0.0;
    return weeklyGoalSavings >= amount;
  }
  
  static bool _checkDailyLogStreak(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final days = requirements['days'] as int;
    final currentStreak = userStats['currentExpenseStreak'] as int? ?? 0;
    return currentStreak >= days;
  }
  
  static bool _checkCategoryBudget(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final categories = requirements['categories'] as int;
    final categoriesUnderBudget = userStats['categoriesUnderBudgetThisWeek'] as int? ?? 0;
    return categoriesUnderBudget >= categories;
  }
  
  static bool _checkMonthlyBudget(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final monthlySpending = userStats['monthlySpending'] as double? ?? 0.0;
    final monthlyBudget = userStats['monthlyBudget'] as double? ?? 0.0;
    return monthlyBudget > 0 && monthlySpending <= monthlyBudget;
  }
  
  static bool _checkSavePercentage(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final percentage = requirements['percentage'] as double;
    final monthlyIncome = userStats['monthlyIncome'] as double? ?? 0.0;
    final monthlySavings = userStats['monthlySavings'] as double? ?? 0.0;
    
    if (monthlyIncome <= 0) return false;
    final savedPercentage = (monthlySavings / monthlyIncome) * 100;
    return savedPercentage >= percentage;
  }
  
  static bool _checkCompleteGoal(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final count = requirements['count'] as int;
    final completedGoalsThisMonth = userStats['completedGoalsThisMonth'] as int? ?? 0;
    return completedGoalsThisMonth >= count;
  }
  
  static bool _checkTrackingStreak(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final days = requirements['days'] as int;
    final currentStreak = userStats['currentExpenseStreak'] as int? ?? 0;
    return currentStreak >= days;
  }
  
  static bool _checkCategorizedExpenses(Map<String, dynamic> userStats, Map<String, dynamic> requirements) {
    final count = requirements['count'] as int;
    final monthlyCategorizedExpenses = userStats['monthlyCategorizedExpenses'] as int? ?? 0;
    return monthlyCategorizedExpenses >= count;
  }
  
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}
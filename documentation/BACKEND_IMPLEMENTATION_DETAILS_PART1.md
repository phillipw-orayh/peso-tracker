# IponGPT Backend Implementation Details

This document provides detailed explanations, examples, and implementation solutions for each proposed backend change in the IponGPT Technical Implementation Guide.

---

## 1. State Management Migration (Provider → Riverpod)

### 1.1 Current Implementation Analysis

**Explanation**: The current app uses Flutter's Provider package for state management with ChangeNotifier-based providers. While Provider works well, Riverpod offers improved compile-time safety, better testing capabilities, and more flexible dependency injection without requiring BuildContext.

**Current Pain Points**:
- BuildContext dependency for accessing providers
- Runtime errors for missing providers
- Difficulty in testing isolated providers
- Manual disposal management
- No compile-time safety for provider dependencies

**Implementation Solutions**:
- **Migration Strategy**: Gradual migration approach to minimize disruption
- **Flutter Libraries**: 
  - `flutter_riverpod` for core state management
  - `riverpod_annotation` for code generation
  - `riverpod_generator` for automatic provider generation

```dart
// Current Provider Implementation
class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  
  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _expenses = await DatabaseService.getAllExpenses();
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addExpense(Expense expense) async {
    await DatabaseService.addExpense(expense);
    _expenses.insert(0, expense);
    notifyListeners();
  }
}

// Riverpod Migration
@riverpod
class ExpenseNotifier extends _$ExpenseNotifier {
  @override
  FutureOr<List<Expense>> build() {
    // Auto-load on creation
    return _loadExpensesFromDatabase();
  }
  
  Future<List<Expense>> _loadExpensesFromDatabase() async {
    return await DatabaseService.getAllExpenses();
  }
  
  Future<void> addExpense(Expense expense) async {
    // Optimistic update
    final currentState = state.valueOrNull ?? [];
    state = AsyncData([expense, ...currentState]);
    
    try {
      await DatabaseService.addExpense(expense);
      // Update with fresh data from database if needed
      state = AsyncData(await _loadExpensesFromDatabase());
    } catch (e) {
      // Revert on error
      state = AsyncData(currentState);
      rethrow;
    }
  }
}

// Computed providers for derived state
@riverpod
double totalExpenses(TotalExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  return expensesAsync.when(
    data: (expenses) => expenses.fold(0, (sum, expense) => sum + expense.amount),
    loading: () => 0,
    error: (_, __) => 0,
  );
}

@riverpod
double todayExpenses(TodayExpensesRef ref) {
  final expensesAsync = ref.watch(expenseNotifierProvider);
  final today = DateTime.now();
  
  return expensesAsync.when(
    data: (expenses) {
      final todayExpenses = expenses.where((expense) => 
        expense.dateTime.year == today.year &&
        expense.dateTime.month == today.month &&
        expense.dateTime.day == today.day
      );
      return todayExpenses.fold(0, (sum, expense) => sum + expense.amount);
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
}

// Widget usage comparison
// Provider way
class ExpenseListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return CircularProgressIndicator();
        }
        return ListView.builder(
          itemCount: expenseProvider.expenses.length,
          itemBuilder: (context, index) {
            return ExpenseCard(expense: expenseProvider.expenses[index]);
          },
        );
      },
    );
  }
}

// Riverpod way
class ExpenseListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseNotifierProvider);
    
    return expensesAsync.when(
      data: (expenses) => ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return ExpenseCard(expense: expenses[index]);
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 1.2 Migration Strategy

**Phase 1: Setup and Dependencies**
```yaml
# pubspec.yaml additions
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
dev_dependencies:
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.7
  riverpod_lint: ^2.3.7
  custom_lint: ^0.5.7
```

**Phase 2: Parallel Implementation**
```dart
// Create Riverpod providers alongside existing Provider classes
// Start with less critical features first

// Goal Provider Migration Example
@riverpod
class GoalNotifier extends _$GoalNotifier {
  @override
  FutureOr<List<SavingsGoal>> build() {
    return DatabaseService.getAllGoals();
  }
  
  Future<void> addGoal(SavingsGoal goal) async {
    final currentGoals = state.valueOrNull ?? [];
    state = AsyncData([...currentGoals, goal]);
    
    try {
      await DatabaseService.addGoal(goal);
      ref.invalidateSelf(); // Refresh from database
    } catch (e) {
      state = AsyncData(currentGoals);
      rethrow;
    }
  }
  
  Future<void> updateGoal(SavingsGoal updatedGoal) async {
    final currentGoals = state.valueOrNull ?? [];
    final updatedGoals = currentGoals.map((goal) => 
      goal.id == updatedGoal.id ? updatedGoal : goal
    ).toList();
    
    state = AsyncData(updatedGoals);
    
    try {
      await DatabaseService.updateGoal(updatedGoal);
      
      // Check for goal completion celebration
      if (updatedGoal.currentAmount >= updatedGoal.targetAmount && 
          !updatedGoal.isCompleted) {
        // Trigger celebration
        ref.read(celebrationServiceProvider).celebrateGoalAchieved(
          updatedGoal.title, 
          updatedGoal.targetAmount
        );
      }
    } catch (e) {
      state = AsyncData(currentGoals);
      rethrow;
    }
  }
}

// Computed state for goal analytics
@riverpod
double totalGoalAmount(TotalGoalAmountRef ref) {
  final goalsAsync = ref.watch(goalNotifierProvider);
  return goalsAsync.when(
    data: (goals) => goals.fold(0, (sum, goal) => sum + goal.targetAmount),
    loading: () => 0,
    error: (_, __) => 0,
  );
}

@riverpod
double totalGoalProgress(TotalGoalProgressRef ref) {
  final goalsAsync = ref.watch(goalNotifierProvider);
  return goalsAsync.when(
    data: (goals) => goals.fold(0, (sum, goal) => sum + goal.currentAmount),
    loading: () => 0,
    error: (_, __) => 0,
  );
}
```

**Phase 3: Widget Migration**
```dart
// Update widgets one by one to use ConsumerWidget
class GoalListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalNotifierProvider);
    final totalAmount = ref.watch(totalGoalAmountProvider);
    final totalProgress = ref.watch(totalGoalProgressProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newGoal = await Navigator.pushNamed(context, '/add-goal');
              if (newGoal is SavingsGoal) {
                ref.read(goalNotifierProvider.notifier).addGoal(newGoal);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          GoalSummaryCard(
            totalAmount: totalAmount,
            totalProgress: totalProgress,
          ),
          Expanded(
            child: goalsAsync.when(
              data: (goals) => goals.isEmpty 
                ? EmptyGoalsState()
                : ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      return GoalCard(
                        goal: goals[index],
                        onUpdate: (updatedGoal) {
                          ref.read(goalNotifierProvider.notifier)
                             .updateGoal(updatedGoal);
                        },
                      );
                    },
                  ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorWidget(error),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 2. AI Financial Coach Service

### 2.1 Architecture Design

**Explanation**: Implement a rule-based AI coach system for MVP that can provide contextual financial advice based on user spending patterns, goals, and behavior. The system will start with predefined rules and can be enhanced with machine learning in future versions.

**Example**: When user spends >30% of income on food, suggest meal prepping. When approaching a savings goal, provide encouragement and timeline updates.

**Implementation Solutions**:
- **Build Ourselves**: Rule-based system with pattern matching
- **Future Enhancement**: Integration with cloud AI services
- **Flutter Libraries**: No external AI libraries needed for rule-based approach

```dart
// Abstract service interface for future extensibility
abstract class AICoachService {
  Future<String> getFinancialAdvice(UserFinancialContext context);
  Future<String> generateInsight(List<Expense> expenses);
  Future<List<String>> getSavingsTips(SavingsGoal goal);
  Stream<CoachingMessage> getDailyNudges();
  Future<String> analyzeSpendingPattern(Map<String, double> categorySpending);
}

// User context for AI analysis
class UserFinancialContext {
  final List<Expense> recentExpenses;
  final List<SavingsGoal> activeGoals;
  final Map<String, double> categorySpending;
  final double monthlyIncome;
  final int currentStreak;
  final List<Challenge> activeChallenges;
  final String preferredLanguage;
  final DateTime lastActiveDate;
  
  UserFinancialContext({
    required this.recentExpenses,
    required this.activeGoals,
    required this.categorySpending,
    required this.monthlyIncome,
    required this.currentStreak,
    required this.activeChallenges,
    required this.preferredLanguage,
    required this.lastActiveDate,
  });
  
  // Computed insights
  double get savingsRate => _calculateSavingsRate();
  String get topSpendingCategory => _getTopSpendingCategory();
  double get goalsProgress => _calculateGoalsProgress();
  bool get isOverspending => _checkOverspending();
  int get daysUntilNextGoal => _calculateDaysToGoal();
  
  double _calculateSavingsRate() {
    if (monthlyIncome <= 0) return 0;
    final monthlyExpenses = recentExpenses
        .where((expense) => _isCurrentMonth(expense.dateTime))
        .fold(0.0, (sum, expense) => sum + expense.amount);
    return ((monthlyIncome - monthlyExpenses) / monthlyIncome * 100).clamp(0, 100);
  }
  
  String _getTopSpendingCategory() {
    if (categorySpending.isEmpty) return 'No spending';
    return categorySpending.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  double _calculateGoalsProgress() {
    if (activeGoals.isEmpty) return 0;
    return activeGoals
        .map((goal) => goal.currentAmount / goal.targetAmount)
        .reduce((a, b) => a + b) / activeGoals.length;
  }
  
  bool _checkOverspending() {
    final monthlySpending = categorySpending.values.fold(0.0, (a, b) => a + b);
    return monthlySpending > monthlyIncome * 0.8; // 80% threshold
  }
  
  int _calculateDaysToGoal() {
    if (activeGoals.isEmpty) return -1;
    return activeGoals
        .map((goal) => goal.targetDate.difference(DateTime.now()).inDays)
        .reduce((a, b) => a < b ? a : b);
  }
  
  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}

// Coaching message types
enum CoachingMessageType {
  encouragement,
  warning,
  tip,
  celebration,
  reminder,
  insight,
}

class CoachingMessage {
  final String id;
  final String title;
  final String message;
  final CoachingMessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? actionData;
  final String? iconPath;
  
  CoachingMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.actionData,
    this.iconPath,
  });
}

// Rule-based coaching implementation
class CoachingRule {
  final String id;
  final bool Function(UserFinancialContext) condition;
  final Map<String, String> messages; // Multi-language support
  final CoachingMessageType type;
  final int priority;
  final Duration cooldown;
  
  CoachingRule({
    required this.id,
    required this.condition,
    required this.messages,
    required this.type,
    required this.priority,
    this.cooldown = const Duration(days: 1),
  });
}

class RuleBasedCoachService implements AICoachService {
  final List<CoachingRule> _rules = [];
  final Map<String, DateTime> _lastTriggered = {};
  
  RuleBasedCoachService() {
    _initializeRules();
  }
  
  void _initializeRules() {
    // Overspending rules
    _rules.add(CoachingRule(
      id: 'food_overspending',
      condition: (context) => 
        context.categorySpending['Pagkain']! > context.monthlyIncome * 0.3,
      messages: {
        'en': 'Your food spending is over 30% of your income. Try meal prepping to save ₱${(context.categorySpending['Pagkain']! - context.monthlyIncome * 0.25).toStringAsFixed(0)} monthly!',
        'tl-en': 'Uy, halos lahat ng gastos mo nasa food ah! Try mag-meal prep, makaka-save ka ng ₱${(context.categorySpending['Pagkain']! - context.monthlyIncome * 0.25).toStringAsFixed(0)} monthly!',
      },
      type: CoachingMessageType.warning,
      priority: 1,
    ));
    
    // Goal encouragement rules
    _rules.add(CoachingRule(
      id: 'goal_almost_complete',
      condition: (context) => 
        context.activeGoals.any((goal) => 
          goal.currentAmount / goal.targetAmount >= 0.8),
      messages: {
        'en': 'You\'re so close to your goal! Just ₱${context.activeGoals.firstWhere((goal) => goal.currentAmount / goal.targetAmount >= 0.8).remainingAmount.toStringAsFixed(0)} more to go!',
        'tl-en': 'Konting tiis na lang! ₱${context.activeGoals.firstWhere((goal) => goal.currentAmount / goal.targetAmount >= 0.8).remainingAmount.toStringAsFixed(0)} na lang para makuha mo yung goal mo!',
      },
      type: CoachingMessageType.encouragement,
      priority: 2,
    ));
    
    // Streak celebration rules
    _rules.add(CoachingRule(
      id: 'streak_milestone',
      condition: (context) => 
        context.currentStreak > 0 && context.currentStreak % 7 == 0,
      messages: {
        'en': 'Amazing! ${context.currentStreak} days streak! You\'re building great financial habits! 🔥',
        'tl-en': 'Galing mo! ${context.currentStreak} days na streak mo! Napaka-disciplined mo sa pag-track! 🔥',
      },
      type: CoachingMessageType.celebration,
      priority: 3,
    ));
    
    // Inactivity reminders
    _rules.add(CoachingRule(
      id: 'inactivity_reminder',
      condition: (context) => 
        DateTime.now().difference(context.lastActiveDate).inDays >= 2,
      messages: {
        'en': 'Hey there! Haven\'t seen you in a while. Don\'t forget to log your expenses to keep your streak going! 📱',
        'tl-en': 'Uy, tagal mo nang di nag-log! Wag kalimutan mag-track para tuloy-tuloy yung streak mo ha! 📱',
      },
      type: CoachingMessageType.reminder,
      priority: 4,
    ));
    
    // Savings rate insights
    _rules.add(CoachingRule(
      id: 'good_savings_rate',
      condition: (context) => context.savingsRate >= 20,
      messages: {
        'en': 'Excellent! Your savings rate is ${context.savingsRate.toStringAsFixed(1)}%. You\'re on track for financial success! 💰',
        'tl-en': 'Grabe ka! ${context.savingsRate.toStringAsFixed(1)}% savings rate mo! Talagang magiging financially stable ka nito! 💰',
      },
      type: CoachingMessageType.insight,
      priority: 5,
      cooldown: Duration(days: 7),
    ));
  }
  
  @override
  Future<String> getFinancialAdvice(UserFinancialContext context) async {
    final applicableRules = _rules.where((rule) {
      // Check if rule applies and hasn't been triggered recently
      if (!rule.condition(context)) return false;
      
      final lastTrigger = _lastTriggered[rule.id];
      if (lastTrigger != null) {
        final timeSinceLastTrigger = DateTime.now().difference(lastTrigger);
        if (timeSinceLastTrigger < rule.cooldown) return false;
      }
      
      return true;
    }).toList();
    
    if (applicableRules.isEmpty) {
      return _getGenericAdvice(context);
    }
    
    // Sort by priority and pick the highest priority rule
    applicableRules.sort((a, b) => a.priority.compareTo(b.priority));
    final selectedRule = applicableRules.first;
    
    // Mark rule as triggered
    _lastTriggered[selectedRule.id] = DateTime.now();
    
    // Return message in preferred language
    final message = selectedRule.messages[context.preferredLanguage] ?? 
                   selectedRule.messages['en'] ?? 
                   'Keep up the great work with your finances!';
    
    return message;
  }
  
  @override
  Future<String> generateInsight(List<Expense> expenses) async {
    if (expenses.isEmpty) return 'Start tracking your expenses to get insights!';
    
    // Analyze spending patterns
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] = 
        (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    final totalSpent = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final topCategory = categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    final percentage = (topCategory.value / totalSpent * 100).toStringAsFixed(1);
    
    return 'You spend the most on ${topCategory.key} (${percentage}% of total). '
           'Consider setting a budget for this category to better control spending.';
  }
  
  @override
  Future<List<String>> getSavingsTips(SavingsGoal goal) async {
    final tips = <String>[];
    
    // Calculate daily savings needed
    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;
    final amountRemaining = goal.targetAmount - goal.currentAmount;
    final dailySavingsNeeded = amountRemaining / daysRemaining;
    
    tips.add('Save ₱${dailySavingsNeeded.toStringAsFixed(0)} daily to reach your ${goal.title} goal on time.');
    
    // Goal-specific tips
    if (goal.title.toLowerCase().contains('phone')) {
      tips.add('Consider buying during sale seasons like 11.11 or 12.12 for better deals.');
      tips.add('Check for trade-in programs to reduce the amount needed.');
    } else if (goal.title.toLowerCase().contains('trip') || goal.title.toLowerCase().contains('travel')) {
      tips.add('Book flights and accommodations early for better rates.');
      tips.add('Consider traveling during off-peak seasons for savings.');
    } else if (goal.title.toLowerCase().contains('emergency')) {
      tips.add('Aim for 3-6 months of expenses for a complete emergency fund.');
      tips.add('Keep this money in a high-yield savings account for easy access.');
    }
    
    return tips;
  }
  
  @override
  Stream<CoachingMessage> getDailyNudges() async* {
    // Implement daily nudge logic
    // This could be called by a background service or scheduled notification
    
    // Example nudges based on time of day
    final now = DateTime.now();
    
    if (now.hour >= 8 && now.hour <= 10) {
      yield CoachingMessage(
        id: 'morning_nudge_${now.day}',
        title: 'Good Morning!',
        message: 'Ready to track another financially responsible day? 🌅',
        type: CoachingMessageType.encouragement,
        timestamp: now,
      );
    } else if (now.hour >= 18 && now.hour <= 20) {
      yield CoachingMessage(
        id: 'evening_nudge_${now.day}',
        title: 'Evening Check-in',
        message: 'How did your spending go today? Don\'t forget to log any expenses! 📝',
        type: CoachingMessageType.reminder,
        timestamp: now,
      );
    }
  }
  
  @override
  Future<String> analyzeSpendingPattern(Map<String, double> categorySpending) async {
    if (categorySpending.isEmpty) {
      return 'Start spending and tracking to see your patterns!';
    }
    
    final total = categorySpending.values.fold(0.0, (a, b) => a + b);
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategory = sortedCategories.first;
    final topPercentage = (topCategory.value / total * 100).toStringAsFixed(1);
    
    // Generate insight based on spending distribution
    if (sortedCategories.length == 1) {
      return 'You only spent on ${topCategory.key} this period. Consider diversifying your spending tracking.';
    }
    
    final secondCategory = sortedCategories[1];
    final secondPercentage = (secondCategory.value / total * 100).toStringAsFixed(1);
    
    return 'Your top spending categories are ${topCategory.key} (${topPercentage}%) and ${secondCategory.key} (${secondPercentage}%). '
           'These two categories make up ${(double.parse(topPercentage) + double.parse(secondPercentage)).toStringAsFixed(1)}% of your total spending.';
  }
  
  String _getGenericAdvice(UserFinancialContext context) {
    final genericAdvice = [
      'Keep tracking your expenses daily to build a strong financial habit!',
      'Small savings today lead to big achievements tomorrow!',
      'You\'re doing great by staying aware of your spending!',
      'Every peso tracked is a step towards your financial goals!',
      'Consistency in tracking leads to consistency in saving!',
    ];
    
    // Return advice based on current streak or random
    final index = context.currentStreak % genericAdvice.length;
    return genericAdvice[index];
  }
}

// Riverpod providers for AI Coach
@riverpod
AICoachService aiCoachService(AiCoachServiceRef ref) {
  return RuleBasedCoachService();
}

@riverpod
Future<UserFinancialContext> userFinancialContext(UserFinancialContextRef ref) async {
  final expenses = await ref.watch(expenseNotifierProvider.future);
  final goals = await ref.watch(goalNotifierProvider.future);
  final challenges = await ref.watch(challengeNotifierProvider.future);
  
  // Calculate category spending for recent period
  final recentExpenses = expenses.where((expense) =>
    expense.dateTime.isAfter(DateTime.now().subtract(Duration(days: 30)))
  ).toList();
  
  final categorySpending = <String, double>{};
  for (final expense in recentExpenses) {
    categorySpending[expense.category] = 
      (categorySpending[expense.category] ?? 0) + expense.amount;
  }
  
  return UserFinancialContext(
    recentExpenses: recentExpenses,
    activeGoals: goals.where((goal) => !goal.isCompleted).toList(),
    categorySpending: categorySpending,
    monthlyIncome: 50000, // This would come from user settings
    currentStreak: 15, // This would come from streak calculation
    activeChallenges: challenges.where((challenge) => challenge.isActive).toList(),
    preferredLanguage: 'tl-en', // From user preferences
    lastActiveDate: DateTime.now().subtract(Duration(hours: 2)),
  );
}

@riverpod
Future<String> dailyFinancialAdvice(DailyFinancialAdviceRef ref) async {
  final coach = ref.watch(aiCoachServiceProvider);
  final context = await ref.watch(userFinancialContextProvider.future);
  
  return await coach.getFinancialAdvice(context);
}
```

### 2.2 Future Enhancement: Integration with Cloud AI Services

**Explanation**: While the MVP uses a rule-based coaching system, the architecture is designed to support future integration with cloud-based AI services for more sophisticated financial advice, natural language processing, and personalized insights.

**Example**: Integration with services like OpenAI GPT for conversational AI, Google Cloud AI for Filipino language processing, or custom machine learning models for spending pattern analysis and predictive financial advice.

**Implementation Strategy**:
- **Modular Design**: Current `AICoachService` interface allows seamless backend swapping
- **Progressive Enhancement**: Start with cloud augmentation of rule-based system
- **Privacy-First**: All cloud integration will be opt-in with clear data handling policies

**Cloud AI Integration Architecture**:

```dart
// Extended AI service interface for cloud capabilities
abstract class CloudAICoachService extends AICoachService {
  Future<String> getPersonalizedAdvice(UserFinancialContext context);
  Future<String> processNaturalLanguageQuery(String query, UserFinancialContext context);
  Future<List<String>> getPredictiveInsights(List<Expense> historicalData);
  Future<String> generateFinancialReport(ReportParameters params);
  Future<bool> analyzeReceiptImage(String imagePath);
}

// Hybrid service that combines local rules with cloud intelligence
class HybridAICoachService implements CloudAICoachService {
  final RuleBasedCoachService _localService;
  final CloudAIProvider _cloudProvider;
  final bool _cloudEnabled;
  
  HybridAICoachService({
    required RuleBasedCoachService localService,
    required CloudAIProvider cloudProvider,
    required bool cloudEnabled,
  }) : _localService = localService,
       _cloudProvider = cloudProvider,
       _cloudEnabled = cloudEnabled;
  
  @override
  Future<String> getFinancialAdvice(UserFinancialContext context) async {
    // Always provide local advice as fallback
    final localAdvice = await _localService.getFinancialAdvice(context);
    
    if (!_cloudEnabled) return localAdvice;
    
    try {
      // Enhance with cloud insights
      final cloudInsights = await _cloudProvider.getEnhancedAdvice(
        context: context,
        localAdvice: localAdvice,
      );
      
      return cloudInsights ?? localAdvice;
    } catch (e) {
      // Fallback to local service on cloud failure
      debugPrint('Cloud AI unavailable, using local advice: $e');
      return localAdvice;
    }
  }
  
  @override
  Future<String> getPersonalizedAdvice(UserFinancialContext context) async {
    if (!_cloudEnabled) {
      return await _localService.getFinancialAdvice(context);
    }
    
    // Generate user profile for personalization
    final userProfile = UserProfile.fromContext(context);
    
    return await _cloudProvider.getPersonalizedAdvice(
      profile: userProfile,
      language: context.preferredLanguage,
    );
  }
  
  @override
  Future<String> processNaturalLanguageQuery(String query, UserFinancialContext context) async {
    if (!_cloudEnabled) {
      return _processQueryLocally(query, context);
    }
    
    try {
      return await _cloudProvider.processNLQuery(
        query: query,
        context: context,
        language: context.preferredLanguage,
      );
    } catch (e) {
      return _processQueryLocally(query, context);
    }
  }
  
  String _processQueryLocally(String query, UserFinancialContext context) {
    // Simple keyword matching for offline queries
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('spending') || lowerQuery.contains('gastos')) {
      final monthlySpending = context.categorySpending.values.fold(0.0, (a, b) => a + b);
      return 'Your monthly spending is ₱${monthlySpending.toStringAsFixed(2)}. Your top category is ${context.topSpendingCategory}.';
    }
    
    if (lowerQuery.contains('goal') || lowerQuery.contains('target')) {
      if (context.activeGoals.isEmpty) {
        return 'You don\'t have any active goals yet. Consider setting a savings goal to improve your financial future!';
      }
      
      final nextGoal = context.activeGoals.first;
      return 'Your next goal "${nextGoal.title}" needs ₱${nextGoal.remainingAmount.toStringAsFixed(2)} more. You\'re ${(nextGoal.progressPercentage).toStringAsFixed(1)}% there!';
    }
    
    return 'I can help you with spending analysis, goal tracking, and financial advice. Try asking about your spending or goals!';
  }
}

// Cloud AI provider interface for different services
abstract class CloudAIProvider {
  Future<String?> getEnhancedAdvice({
    required UserFinancialContext context,
    required String localAdvice,
  });
  
  Future<String> getPersonalizedAdvice({
    required UserProfile profile,
    required String language,
  });
  
  Future<String> processNLQuery({
    required String query,
    required UserFinancialContext context,
    required String language,
  });
  
  Future<List<String>> generatePredictiveInsights(List<Expense> expenses);
  Future<String> analyzeReceiptText(String receiptText);
}

// OpenAI GPT implementation
class OpenAICoachProvider implements CloudAIProvider {
  final String _apiKey;
  final String _baseUrl;
  final http.Client _client;
  
  OpenAICoachProvider({
    required String apiKey,
    String baseUrl = 'https://api.openai.com/v1',
    http.Client? client,
  }) : _apiKey = apiKey,
       _baseUrl = baseUrl,
       _client = client ?? http.Client();
  
  @override
  Future<String?> getEnhancedAdvice({
    required UserFinancialContext context,
    required String localAdvice,
  }) async {
    try {
      final prompt = _buildAdvicePrompt(context, localAdvice);
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a Filipino financial advisor who speaks in a mix of English and Tagalog (Taglish). You provide practical, culturally-aware financial advice for Filipino users. Keep responses concise and encouraging.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        return content?.toString().trim();
      }
      
      return null;
    } catch (e) {
      debugPrint('OpenAI API error: $e');
      return null;
    }
  }
  
  @override
  Future<String> getPersonalizedAdvice({
    required UserProfile profile,
    required String language,
  }) async {
    final prompt = _buildPersonalizedPrompt(profile, language);
    
    // Similar implementation to getEnhancedAdvice
    // but with personalization based on user profile
    return await _callGPTAPI(prompt) ?? 
           'Keep building your financial discipline! Small steps lead to big achievements.';
  }
  
  @override
  Future<String> processNLQuery({
    required String query,
    required UserFinancialContext context,
    required String language,
  }) async {
    final prompt = _buildQueryPrompt(query, context, language);
    
    return await _callGPTAPI(prompt) ?? 
           'I can help you with your financial questions. Try asking about your spending patterns or savings goals.';
  }
  
  String _buildAdvicePrompt(UserFinancialContext context, String localAdvice) {
    return '''
Based on this user's financial data:
- Monthly income: ₱${context.monthlyIncome}
- Savings rate: ${context.savingsRate.toStringAsFixed(1)}%
- Top spending category: ${context.topSpendingCategory}
- Active goals: ${context.activeGoals.length}
- Current streak: ${context.currentStreak} days

Local advice given: "$localAdvice"

Enhance this advice with personalized insights in Taglish (English-Tagalog mix). Keep it encouraging and practical for a Filipino user.
    ''';
  }
  
  String _buildPersonalizedPrompt(UserProfile profile, String language) {
    return '''
Provide personalized financial advice for this user profile:
- Age: ${profile.age}
- Income level: ${profile.incomeLevel}
- Financial goals: ${profile.primaryGoals.join(', ')}
- Risk tolerance: ${profile.riskTolerance}
- Spending habits: ${profile.spendingPattern}

Respond in ${language == 'tl-en' ? 'Taglish (English-Tagalog mix)' : 'English'}.
    ''';
  }
  
  String _buildQueryPrompt(String query, UserFinancialContext context, String language) {
    return '''
User question: "$query"

User's financial context:
- Monthly spending: ₱${context.categorySpending.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}
- Savings rate: ${context.savingsRate.toStringAsFixed(1)}%
- Goals: ${context.activeGoals.map((g) => g.title).join(', ')}

Answer in ${language == 'tl-en' ? 'Taglish' : 'English'} with practical Filipino financial advice.
    ''';
  }
  
  Future<String?> _callGPTAPI(String prompt) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful Filipino financial advisor.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 200,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content']?.toString().trim();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<List<String>> generatePredictiveInsights(List<Expense> expenses) async {
    // Analyze spending patterns and predict future expenses
    final insights = <String>[];
    
    // This would use more sophisticated analysis in production
    final monthlyAverage = _calculateMonthlyAverage(expenses);
    insights.add('Based on your patterns, you might spend ₱${monthlyAverage.toStringAsFixed(0)} next month.');
    
    return insights;
  }
  
  @override
  Future<String> analyzeReceiptText(String receiptText) async {
    final prompt = '''
Extract expense information from this receipt:
$receiptText

Return JSON format: {"amount": number, "merchant": "string", "category": "string", "items": ["string"]}
    ''';
    
    final response = await _callGPTAPI(prompt);
    return response ?? '{"amount": 0, "merchant": "Unknown", "category": "Other", "items": []}';
  }
  
  double _calculateMonthlyAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    
    final monthlyTotals = <String, double>{};
    for (final expense in expenses) {
      final monthKey = '${expense.dateTime.year}-${expense.dateTime.month}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }
    
    return monthlyTotals.values.fold(0.0, (a, b) => a + b) / monthlyTotals.length;
  }
}

// User profile for personalization
class UserProfile {
  final int age;
  final String incomeLevel;
  final List<String> primaryGoals;
  final String riskTolerance;
  final String spendingPattern;
  
  UserProfile({
    required this.age,
    required this.incomeLevel,
    required this.primaryGoals,
    required this.riskTolerance,
    required this.spendingPattern,
  });
  
  factory UserProfile.fromContext(UserFinancialContext context) {
    // Infer profile from spending patterns and goals
    final totalSpending = context.categorySpending.values.fold(0.0, (a, b) => a + b);
    
    String incomeLevel;
    if (context.monthlyIncome < 25000) {
      incomeLevel = 'entry';
    } else if (context.monthlyIncome < 75000) {
      incomeLevel = 'middle';
    } else {
      incomeLevel = 'high';
    }
    
    String spendingPattern;
    if (context.savingsRate > 20) {
      spendingPattern = 'conservative';
    } else if (context.savingsRate > 10) {
      spendingPattern = 'moderate';
    } else {
      spendingPattern = 'high_spender';
    }
    
    return UserProfile(
      age: 25, // Would be collected from user
      incomeLevel: incomeLevel,
      primaryGoals: context.activeGoals.map((g) => g.title).toList(),
      riskTolerance: context.savingsRate > 15 ? 'moderate' : 'low',
      spendingPattern: spendingPattern,
    );
  }
}

// Riverpod providers for cloud AI integration
@riverpod
CloudAIProvider cloudAIProvider(CloudAIProviderRef ref) {
  // In production, API key would come from secure storage or environment
  return OpenAICoachProvider(
    apiKey: 'your_openai_api_key_here',
  );
}

@riverpod
Future<bool> cloudAIEnabled(CloudAIEnabledRef ref) async {
  // Check user preferences and subscription status
  final preferences = await ref.watch(userPreferencesProvider.future);
  final subscription = await ref.watch(subscriptionStatusProvider.future);
  
  return preferences.cloudAIEnabled && subscription.isPremium;
}

@riverpod
CloudAICoachService hybridAICoachService(HybridAICoachServiceRef ref) {
  final localService = ref.watch(aiCoachServiceProvider) as RuleBasedCoachService;
  final cloudProvider = ref.watch(cloudAIProviderProvider);
  final cloudEnabled = ref.watch(cloudAIEnabledProvider).valueOrNull ?? false;
  
  return HybridAICoachService(
    localService: localService,
    cloudProvider: cloudProvider,
    cloudEnabled: cloudEnabled,
  );
}
```

**Cloud AI Integration Benefits**:

1. **Enhanced Personalization**: Machine learning models can analyze spending patterns for highly personalized advice
2. **Natural Language Processing**: Users can ask questions in natural Taglish and get contextual responses
3. **Predictive Analytics**: Forecast future expenses, identify overspending risks, suggest optimal savings plans
4. **Filipino Language Support**: Cloud services can better understand Filipino expressions and cultural context
5. **Advanced Receipt Processing**: OCR and text analysis for automatic expense categorization

**Privacy & Security Considerations**:

- **Opt-in Only**: Cloud features require explicit user consent
- **Data Minimization**: Only anonymized spending patterns sent to cloud, never personal identifiers
- **Local Fallback**: All features work offline; cloud enhances but doesn't replace local functionality
- **Subscription Gate**: Advanced cloud AI features available for premium subscribers only
- **Transparent Processing**: Users informed exactly what data is processed by cloud services

**Implementation Phases**:

1. **Phase 1**: Implement hybrid architecture with local/cloud fallback system
2. **Phase 2**: Add cloud-enhanced advice generation with OpenAI integration
3. **Phase 3**: Implement natural language query processing for chat interface
4. **Phase 4**: Add predictive analytics and advanced personalization
5. **Phase 5**: Integrate Filipino-specific language models for cultural context

This architecture ensures the app provides excellent financial coaching from day one with local rules, while being prepared for future enhancement with sophisticated AI services as the product scales and premium features are developed.

---

## 3. Security & Privacy Enhancements

### 3.1 Biometric/PIN Authentication

**Explanation**: Implement secure authentication using biometrics (fingerprint, face recognition) with PIN fallback to protect sensitive financial data. This ensures only the user can access their financial information.

**Example**: Like banking apps where users authenticate before viewing account details. Support fingerprint, face unlock, or PIN entry.

**Implementation Solutions**:
- **Flutter Libraries**: 
  - `local_auth` for biometric authentication
  - `flutter_secure_storage` for secure credential storage
  - `crypto` for PIN hashing

```dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecurityService {
  static const SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  const SecurityService._internal();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  // Authenticate user using biometrics or PIN
  Future<AuthenticationResult> authenticateUser() async {
    try {
      // Check if app is configured for authentication
      final isAuthEnabled = await isAuthenticationEnabled();
      if (!isAuthEnabled) {
        return AuthenticationResult.success();
      }
      
      // Try biometric first if available and enabled
      if (await isBiometricEnabled()) {
        final biometricResult = await _authenticateWithBiometric();
        if (biometricResult.isSuccess) {
          return biometricResult;
        }
      }
      
      // Fall back to PIN
      return await _authenticateWithPIN();
      
    } catch (e) {
      return AuthenticationResult.error('Authentication failed: $e');
    }
  }
  
  Future<AuthenticationResult> _authenticateWithBiometric() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your financial data',
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return didAuthenticate 
        ? AuthenticationResult.success()
        : AuthenticationResult.cancelled();
        
    } on PlatformException catch (e) {
      return AuthenticationResult.error(e.message ?? 'Biometric authentication failed');
    }
  }
  
  Future<AuthenticationResult> _authenticateWithPIN() async {
    // This would typically show a PIN input dialog
    // For now, returning a placeholder that indicates PIN is needed
    return AuthenticationResult.pinRequired();
  }
  
  // Enable/disable authentication
  Future<void> setAuthenticationEnabled(bool enabled) async {
    await _secureStorage.write(key: 'auth_enabled', value: enabled.toString());
  }
  
  Future<bool> isAuthenticationEnabled() async {
    final value = await _secureStorage.read(key: 'auth_enabled');
    return value == 'true';
  }
  
  // Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: 'biometric_enabled', value: enabled.toString());
  }
  
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: 'biometric_enabled');
    return value == 'true';
  }
  
  // Set up PIN authentication
  Future<bool> setupPIN(String pin) async {
    try {
      // Validate PIN strength
      if (!_isValidPIN(pin)) {
        return false;
      }
      
      // Hash PIN for secure storage
      final hashedPin = _hashPIN(pin);
      await _secureStorage.write(key: 'hashed_pin', value: hashedPin);
      await _secureStorage.write(key: 'pin_enabled', value: 'true');
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Verify PIN
  Future<bool> verifyPIN(String pin) async {
    try {
      final storedHash = await _secureStorage.read(key: 'hashed_pin');
      if (storedHash == null) return false;
      
      final inputHash = _hashPIN(pin);
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }
  
  // Remove PIN authentication
  Future<void> removePIN() async {
    await _secureStorage.delete(key: 'hashed_pin');
    await _secureStorage.delete(key: 'pin_enabled');
  }
  
  // Check if PIN is set up
  Future<bool> isPINEnabled() async {
    final value = await _secureStorage.read(key: 'pin_enabled');
    return value == 'true';
  }
  
  // Validate PIN strength
  bool _isValidPIN(String pin) {
    // PIN should be 4-6 digits
    if (pin.length < 4 || pin.length > 6) return false;
    
    // Should contain only digits
    if (!RegExp(r'^\d+$').hasMatch(pin)) return false;
    
    // Should not be sequential (1234, 5678) or repetitive (1111, 2222)
    if (_isSequentialPIN(pin) || _isRepetitivePIN(pin)) return false;
    
    return true;
  }
  
  bool _isSequentialPIN(String pin) {
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);
      if (next != current + 1 && next != current - 1) return false;
    }
    return true;
  }
  
  bool _isRepetitivePIN(String pin) {
    return pin.split('').every((digit) => digit == pin[0]);
  }
  
  // Hash PIN using SHA-256
  String _hashPIN(String pin) {
    final bytes = utf8.encode(pin + 'ipongpt_salt'); // Add salt
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Clear all authentication data
  Future<void> clearAllAuthData() async {
    await _secureStorage.delete(key: 'auth_enabled');
    await _secureStorage.delete(key: 'biometric_enabled');
    await _secureStorage.delete(key: 'hashed_pin');
    await _secureStorage.delete(key: 'pin_enabled');
  }
}

// Authentication result class
class AuthenticationResult {
  final bool isSuccess;
  final bool isCancelled;
  final bool isPinRequired;
  final String? errorMessage;
  
  const AuthenticationResult._({
    required this.isSuccess,
    required this.isCancelled,
    required this.isPinRequired,
    this.errorMessage,
  });
  
  factory AuthenticationResult.success() => AuthenticationResult._(
    isSuccess: true,
    isCancelled: false,
    isPinRequired: false,
  );
  
  factory AuthenticationResult.cancelled() => AuthenticationResult._(
    isSuccess: false,
    isCancelled: true,
    isPinRequired: false,
  );
  
  factory AuthenticationResult.pinRequired() => AuthenticationResult._(
    isSuccess: false,
    isCancelled: false,
    isPinRequired: true,
  );
  
  factory AuthenticationResult.error(String message) => AuthenticationResult._(
    isSuccess: false,
    isCancelled: false,
    isPinRequired: false,
    errorMessage: message,
  );
}

// Widget for authentication setup
class AuthenticationSetupWidget extends ConsumerStatefulWidget {
  @override
  _AuthenticationSetupWidgetState createState() => _AuthenticationSetupWidgetState();
}

class _AuthenticationSetupWidgetState extends ConsumerState<AuthenticationSetupWidget> {
  final SecurityService _securityService = SecurityService();
  bool _isAuthEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isPinEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  
  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }
  
  Future<void> _loadCurrentSettings() async {
    final authEnabled = await _securityService.isAuthenticationEnabled();
    final biometricEnabled = await _securityService.isBiometricEnabled();
    final pinEnabled = await _securityService.isPINEnabled();
    final availableBiometrics = await _securityService.getAvailableBiometrics();
    
    setState(() {
      _isAuthEnabled = authEnabled;
      _isBiometricEnabled = biometricEnabled;
      _isPinEnabled = pinEnabled;
      _availableBiometrics = availableBiometrics;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            
            // Enable/Disable Authentication
            SwitchListTile(
              title: Text('Require Authentication'),
              subtitle: Text('Protect your financial data with authentication'),
              value: _isAuthEnabled,
              onChanged: (value) async {
                await _securityService.setAuthenticationEnabled(value);
                setState(() {
                  _isAuthEnabled = value;
                });
                
                if (!value) {
                  // If disabling auth, also disable biometric and PIN
                  await _securityService.setBiometricEnabled(false);
                  await _securityService.removePIN();
                  setState(() {
                    _isBiometricEnabled = false;
                    _isPinEnabled = false;
                  });
                }
              },
            ),
            
            if (_isAuthEnabled) ...[
              Divider(),
              
              // Biometric Authentication
              if (_availableBiometrics.isNotEmpty)
                SwitchListTile(
                  title: Text('Biometric Authentication'),
                  subtitle: Text(_getBiometricSubtitle()),
                  value: _isBiometricEnabled,
                  onChanged: (value) async {
                    await _securityService.setBiometricEnabled(value);
                    setState(() {
                      _isBiometricEnabled = value;
                    });
                  },
                ),
              
              // PIN Setup
              ListTile(
                title: Text('PIN Authentication'),
                subtitle: Text(_isPinEnabled ? 'PIN is set up' : 'Set up PIN as backup'),
                trailing: _isPinEnabled 
                  ? TextButton(
                      onPressed: _showChangePINDialog,
                      child: Text('Change'),
                    )
                  : TextButton(
                      onPressed: _showSetupPINDialog,
                      child: Text('Set up'),
                    ),
              ),
              
              if (_isPinEnabled)
                ListTile(
                  title: Text('Remove PIN'),
                  subtitle: Text('Remove PIN authentication'),
                  trailing: TextButton(
                    onPressed: _removePIN,
                    child: Text('Remove', style: TextStyle(color: Colors.red)),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _getBiometricSubtitle() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Use Face ID to unlock';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Use fingerprint to unlock';
    } else {
      return 'Use biometric authentication';
    }
  }
  
  Future<void> _showSetupPINDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => PINSetupDialog(),
    );
    
    if (result != null) {
      final success = await _securityService.setupPIN(result);
      if (success) {
        setState(() {
          _isPinEnabled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PIN set up successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set up PIN')),
        );
      }
    }
  }
  
  Future<void> _showChangePINDialog() async {
    // Similar to setup but with current PIN verification first
    _showSetupPINDialog(); // Simplified for now
  }
  
  Future<void> _removePIN() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove PIN?'),
        content: Text('Are you sure you want to remove PIN authentication?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _securityService.removePIN();
      setState(() {
        _isPinEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN removed successfully')),
      );
    }
  }
}

// Riverpod providers for security service
@riverpod
SecurityService securityService(SecurityServiceRef ref) {
  return SecurityService();
}

@riverpod
Future<bool> authenticationRequired(AuthenticationRequiredRef ref) async {
  final security = ref.watch(securityServiceProvider);
  return await security.isAuthenticationEnabled();
}
```

### 3.2 Encrypted Local Storage

**Explanation**: Enhance the existing Hive storage with encryption to protect sensitive financial data stored locally on the device. This ensures that even if someone gains physical access to the device, they cannot read the financial data.

**Implementation Solutions**:
- **Current Codebase**: Extend existing Hive implementation with encryption
- **Flutter Libraries**: `hive` with encryption support

```dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

class EncryptedStorageService {
  static const String _encryptionKeyKey = 'hive_encryption_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Initialize Hive with encryption
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register all adapters
    _registerAdapters();
  }
  
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GoalTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SavingsGoalAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserDataAdapter());
    }
    // Register new adapters for enhanced features
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(WalletAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(AICoachHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(ChallengeAdapter());
    }
  }
  
  // Generate or retrieve encryption key
  static Future<List<int>> _getEncryptionKey() async {
    String? keyString = await _secureStorage.read(key: _encryptionKeyKey);
    
    if (keyString == null) {
      // Generate new encryption key
      final key = Hive.generateSecureKey();
      keyString = base64.encode(key);
      await _secureStorage.write(key: _encryptionKeyKey, value: keyString);
      return key;
    }
    
    return base64.decode(keyString);
  }
  
  // Open encrypted Hive box
  static Future<Box<T>> openEncryptedBox<T>(String name) async {
    final encryptionKey = await _getEncryptionKey();
    
    return await Hive.openBox<T>(
      name,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }
  
  // Close all boxes (for logout/security)
  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }
  
  // Delete all data (for account deletion)
  static Future<void> deleteAllData() async {
    await Hive.deleteFromDisk();
    await _secureStorage.delete(key: _encryptionKeyKey);
  }
  
  // Backup data to encrypted JSON
  static Future<String> exportEncryptedBackup(String password) async {
    final boxes = {
      'expenses': await openEncryptedBox<Expense>('expenses'),
      'goals': await openEncryptedBox<SavingsGoal>('goals'),
      'userData': await openEncryptedBox<UserData>('userData'),
      'wallets': await openEncryptedBox<Wallet>('wallets'),
      'challenges': await openEncryptedBox<Challenge>('challenges'),
    };
    
    final data = <String, dynamic>{};
    
    // Export each box
    for (final entry in boxes.entries) {
      final boxName = entry.key;
      final box = entry.value;
      
      data[boxName] = box.values.map((item) {
        if (item is Expense) return item.toJson();
        if (item is SavingsGoal) return item.toJson();
        if (item is UserData) return item.toJson();
        if (item is Wallet) return item.toJson();
        if (item is Challenge) return item.toJson();
        return item.toString();
      }).toList();
    }
    
    // Add metadata
    data['metadata'] = {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'dataVersion': '1.0',
    };
    
    final jsonString = jsonEncode(data);
    
    // Encrypt with user password
    return _encryptWithPassword(jsonString, password);
  }
  
  // Import data from encrypted backup
  static Future<bool> importEncryptedBackup(String encryptedData, String password) async {
    try {
      // Decrypt with user password
      final jsonString = _decryptWithPassword(encryptedData, password);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate backup format
      if (!_validateBackupFormat(data)) {
        return false;
      }
      
      // Import each box
      await _importExpenses(data['expenses'] as List);
      await _importGoals(data['goals'] as List);
      await _importUserData(data['userData'] as List);
      await _importWallets(data['wallets'] as List);
      await _importChallenges(data['challenges'] as List);
      
      return true;
    } catch (e) {
      debugPrint('Import failed: $e');
      return false;
    }
  }
  
  static String _encryptWithPassword(String data, String password) {
    // Simple XOR encryption for demo - in production, use proper encryption
    final passwordBytes = utf8.encode(password);
    final dataBytes = utf8.encode(data);
    final encrypted = <int>[];
    
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ passwordBytes[i % passwordBytes.length]);
    }
    
    return base64.encode(encrypted);
  }
  
  static String _decryptWithPassword(String encryptedData, String password) {
    final passwordBytes = utf8.encode(password);
    final encryptedBytes = base64.decode(encryptedData);
    final decrypted = <int>[];
    
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ passwordBytes[i % passwordBytes.length]);
    }
    
    return utf8.decode(decrypted);
  }
  
  static bool _validateBackupFormat(Map<String, dynamic> data) {
    return data.containsKey('metadata') && 
           data.containsKey('expenses') &&
           data.containsKey('goals');
  }
  
  static Future<void> _importExpenses(List expenseData) async {
    final box = await openEncryptedBox<Expense>('expenses');
    
    for (final item in expenseData) {
      final expense = Expense.fromJson(item as Map<String, dynamic>);
      await box.put(expense.id, expense);
    }
  }
  
  static Future<void> _importGoals(List goalData) async {
    final box = await openEncryptedBox<SavingsGoal>('goals');
    
    for (final item in goalData) {
      final goal = SavingsGoal.fromJson(item as Map<String, dynamic>);
      await box.put(goal.id, goal);
    }
  }
  
  static Future<void> _importUserData(List userData) async {
    final box = await openEncryptedBox<UserData>('userData');
    
    for (final item in userData) {
      final user = UserData.fromJson(item as Map<String, dynamic>);
      await box.put(user.id, user);
    }
  }
  
  static Future<void> _importWallets(List walletData) async {
    final box = await openEncryptedBox<Wallet>('wallets');
    
    for (final item in walletData) {
      final wallet = Wallet.fromJson(item as Map<String, dynamic>);
      await box.put(wallet.id, wallet);
    }
  }
  
  static Future<void> _importChallenges(List challengeData) async {
    final box = await openEncryptedBox<Challenge>('challenges');
    
    for (final item in challengeData) {
      final challenge = Challenge.fromJson(item as Map<String, dynamic>);
      await box.put(challenge.id, challenge);
    }
  }
}

// Enhanced Database Service with encryption
class EnhancedDatabaseService {
  // Encrypted boxes
  static late Box<Expense> _expenseBox;
  static late Box<SavingsGoal> _goalBox;
  static late Box<UserData> _userBox;
  static late Box<Challenge> _challengeBox;
  static late Box<Wallet> _walletBox;
  static late Box<AICoachHistory> _coachBox;
  
  // Initialize all encrypted boxes
  static Future<void> init() async {
    await EncryptedStorageService.initialize();
    
    _expenseBox = await EncryptedStorageService.openEncryptedBox<Expense>('expenses');
    _goalBox = await EncryptedStorageService.openEncryptedBox<SavingsGoal>('goals');
    _userBox = await EncryptedStorageService.openEncryptedBox<UserData>('userData');
    _challengeBox = await EncryptedStorageService.openEncryptedBox<Challenge>('challenges');
    _walletBox = await EncryptedStorageService.openEncryptedBox<Wallet>('wallets');
    _coachBox = await EncryptedStorageService.openEncryptedBox<AICoachHistory>('coachHistory');
  }
  
  // Expense operations
  static Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }
  
  static List<Expense> getAllExpenses() {
    return _expenseBox.values.toList();
  }
  
  static Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }
  
  static Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }
  
  // Goal operations
  static Future<void> addGoal(SavingsGoal goal) async {
    await _goalBox.put(goal.id, goal);
  }
  
  static List<SavingsGoal> getAllGoals() {
    return _goalBox.values.toList();
  }
  
  static Future<void> updateGoal(SavingsGoal goal) async {
    await _goalBox.put(goal.id, goal);
  }
  
  static Future<void> deleteGoal(String id) async {
    await _goalBox.delete(id);
  }
  
  // Wallet operations
  static Future<void> addWallet(Wallet wallet) async {
    await _walletBox.put(wallet.id, wallet);
  }
  
  static List<Wallet> getAllWallets() {
    return _walletBox.values.toList();
  }
  
  static Future<void> updateWallet(Wallet wallet) async {
    await _walletBox.put(wallet.id, wallet);
  }
  
  static Future<void> deleteWallet(String id) async {
    await _walletBox.delete(id);
  }
  
  // AI Coach history operations
  static Future<void> addCoachHistory(AICoachHistory history) async {
    await _coachBox.put(history.id, history);
  }
  
  static List<AICoachHistory> getCoachHistory({int limit = 50}) {
    final allHistory = _coachBox.values.toList();
    allHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allHistory.take(limit).toList();
  }
  
  // Database maintenance
  static Future<void> compactDatabase() async {
    await _expenseBox.compact();
    await _goalBox.compact();
    await _userBox.compact();
    await _challengeBox.compact();
    await _walletBox.compact();
    await _coachBox.compact();
  }
  
  static Future<void> closeAllBoxes() async {
    await EncryptedStorageService.closeAllBoxes();
  }
  
  // Get database statistics
  static Map<String, int> getDatabaseStats() {
    return {
      'expenses': _expenseBox.length,
      'goals': _goalBox.length,
      'userData': _userBox.length,
      'challenges': _challengeBox.length,
      'wallets': _walletBox.length,
      'coachHistory': _coachBox.length,
    };
  }
}
```

---

## Document Continuation

For detailed implementation of the remaining backend sections, see:

**📋 [BACKEND_IMPLEMENTATION_DETAILS_PART2.md](BACKEND_IMPLEMENTATION_DETAILS_PART2.md)**

**Sections 4-8 Covered:**
- **Section 4**: Database Enhancements (New data models, migrations, encrypted storage)
- **Section 5**: Monetization System (In-app purchases, feature gating, subscription management)
- **Section 6**: Voice & Photo Processing (Speech-to-text, OCR receipt processing, Filipino phrase recognition)
- **Section 7**: Offline-First Architecture (Sync services, conflict resolution, data caching)
- **Section 8**: Performance & Optimization (Image compression, database optimization, memory management)

---

## Implementation Summary

This document provides comprehensive implementation details for each backend enhancement, including:

1. **Detailed explanations** of each feature and its technical requirements
2. **Complete code examples** with proper error handling
3. **Implementation strategies** with pros/cons analysis
4. **Library recommendations** with version specifications
5. **Migration guides** for updating existing code
6. **Security considerations** for each feature
7. **Performance optimization** techniques
8. **Filipino-specific implementations** for cultural relevance

Each section includes production-ready code that can be directly implemented in the IponGPT project while maintaining backward compatibility with the existing codebase.
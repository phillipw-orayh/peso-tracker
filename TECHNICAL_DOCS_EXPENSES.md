# PesoTracker Expense System - Technical Documentation

## Executive Summary

The Expense System in PesoTracker is the core financial tracking component that enables Filipino users to record, categorize, and analyze their spending patterns. This system serves as the foundation for streak tracking, challenge completion, and financial insights within the gamification framework.

## Core Architecture

### 1. Data Models

#### Expense Model (`lib/shared/models/expense.dart`)

**Primary Structure:**
```dart
@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0) String id;                    // Unique identifier
  @HiveField(1) double amount;                // Expense amount in pesos
  @HiveField(2) String category;              // Primary category
  @HiveField(3) String? subcategory;          // Optional subcategory
  @HiveField(4) String description;           // User description
  @HiveField(5) DateTime dateTime;            // Transaction timestamp
  @HiveField(6) String? receiptPath;          // Photo receipt path
  @HiveField(7) String? location;             // Transaction location
  @HiveField(8) Map<String, dynamic>? metadata; // Additional data
}
```

**Key Characteristics:**
- **TypeId 0**: Primary data type in Hive storage
- **Immutable Operations**: Uses copyWith() pattern
- **Rich Metadata**: Supports extensible additional information
- **Media Support**: Receipt photo attachment capability

#### Category System

**Predefined Categories:**
- Food & Dining (Pagkain)
- Transportation (Transportasyon)
- Shopping (Pamimili)
- Bills & Utilities (Mga Bayarin)
- Healthcare (Kalusugan)
- Entertainment (Aliw)
- Education (Edukasyon)
- Savings & Investment (Ipon)

**Subcategory Examples:**
```dart
'Food & Dining': ['Restaurant', 'Fast Food', 'Groceries', 'Coffee']
'Transportation': ['Jeepney', 'Taxi', 'Gas', 'Parking']
'Shopping': ['Clothes', 'Electronics', 'Home Items', 'Gifts']
```

### 2. State Management - ExpenseProvider

#### Core State Variables
```dart
class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];             // All expenses (sorted by date desc)
  bool _isLoading = false;                  // Loading state indicator
}
```

#### Computed Analytics
```dart
// Time-based totals
double get totalExpensesThisMonth    // Current month spending
double get totalExpensesToday        // Today's spending

// Category analysis
Map<String, double> get expensesByCategory // Category breakdown

// Date range queries
List<Expense> getExpensesForDateRange(DateTime start, DateTime end)
```

### 3. Database Integration

#### Hive Storage Configuration
- **TypeId**: 0 (Primary expense type)
- **Storage Method**: Local binary storage
- **Indexing**: Sorted by dateTime (descending)
- **Persistence**: Automatic via HiveObject

#### CRUD Operations
```dart
// Create
await DatabaseService.addExpense(expense);

// Read
List<Expense> expenses = DatabaseService.getAllExpenses();

// Update  
await DatabaseService.updateExpense(expense);

// Delete
await DatabaseService.deleteExpense(id);
```

## Expense Lifecycle Management

### 1. Expense Creation Process

**User Journey:**
1. User taps "Add Expense" floating action button
2. Expense form modal appears with:
   - Amount input (peso validation)
   - Category/subcategory selection
   - Description field
   - Date/time picker (defaults to now)
   - Optional receipt photo
   - Optional location (GPS/manual)
3. Client-side validation
4. Expense saved to Hive database
5. ExpenseProvider state updated
6. Challenge system notified
7. UI refreshed with new expense

**Input Validation:**
```dart
// Amount validation
if (amount <= 0 || amount > 999999999) {
  throw ValidationException('Invalid amount');
}

// Description validation  
if (description.trim().isEmpty) {
  throw ValidationException('Description required');
}

// Date validation
if (dateTime.isAfter(DateTime.now().add(Duration(hours: 1)))) {
  throw ValidationException('Future dates not allowed');
}
```

### 2. Expense Editing & Updates

**Editable Fields:**
- Amount (with recalculation triggers)
- Category/subcategory (affects analytics)
- Description
- Date/time (within reasonable bounds)
- Receipt photo (add/remove/replace)

**Update Process:**
```dart
Future<void> updateExpense(Expense expense) async {
  try {
    await DatabaseService.updateExpense(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Re-sort
      notifyListeners();
      
      // Notify challenge system of update
      challengeProvider.onExpenseUpdated();
    }
  } catch (e) {
    debugPrint('Error updating expense: $e');
    rethrow;
  }
}
```

### 3. Expense Deletion

**Deletion Process:**
1. User confirms deletion (confirmation dialog)
2. Expense removed from database
3. Provider state updated
4. Related analytics recalculated
5. Challenge progress potentially affected

**Soft Delete Option:**
- Could implement soft delete with `isDeleted` flag
- Maintains data integrity for analytics
- Allows undo functionality

## Integration with Gamification System

### 1. Streak System Integration

#### Primary Streak: Daily Expense Logging

**Streak Calculation Logic:**
```dart
// Current streak calculation in ChallengeProvider
int calculateExpenseStreak() {
  int currentStreak = 0;
  DateTime checkDate = DateTime.now();
  
  for (int i = 0; i < 365; i++) {
    final dayExpenses = expenses.where((e) => 
      _isSameDay(e.dateTime, checkDate)
    ).toList();
    
    if (dayExpenses.isNotEmpty) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      break; // Streak broken
    }
  }
  
  return currentStreak;
}
```

**Streak Types Affected by Expenses:**
1. **Logging Streak**: Consecutive days with at least 1 expense logged
2. **Budget Streak**: Days staying under daily budget
3. **Category Streak**: Consistent categorization
4. **Detailed Expense Streak**: Expenses with descriptions/receipts

#### Streak Impact on User Experience

**Milestone Celebrations:**
- 7-day logging streak: "Great Start!" notification
- 30-day streak: "Monthly Champion" badge + confetti
- 100-day streak: "Discipline Master" achievement
- 365-day streak: "Year of Tracking" legendary status

**Streak Motivation Features:**
- Progress rings in home screen
- Streak counter prominently displayed
- Gentle reminders when streak at risk
- Recovery encouragement after broken streaks

### 2. Challenge System Integration

#### Expense-Related Challenges

**Daily Challenges:**
```dart
'daily_budget_keeper': {
  'action': 'spend_limit',
  'amount': 500.0,  // Stay under ₱500/day
  'timeframe': 'daily',
  'points': 10
}

'expense_logger': {
  'action': 'log_expense', 
  'count': 1,  // Log at least 1 expense
  'timeframe': 'daily',
  'points': 5
}
```

**Weekly Challenges:**
```dart
'detailed_tracker': {
  'action': 'detailed_expenses',
  'count': 10,  // 10 expenses with descriptions
  'timeframe': 'weekly',
  'points': 25
}

'category_master': {
  'action': 'categorized_expenses',
  'count': 20,  // All expenses categorized
  'timeframe': 'weekly', 
  'points': 20
}
```

**Monthly Challenges:**
```dart
'budget_champion': {
  'action': 'monthly_budget',
  'amount': 15000.0,  // Stay under monthly budget
  'timeframe': 'monthly',
  'points': 100
}

'receipt_collector': {
  'action': 'expenses_with_receipts',
  'count': 50,  // 50 expenses with photos
  'timeframe': 'monthly',
  'points': 75
}
```

#### Challenge Progress Tracking

**Stats Monitored by ChallengeProvider:**
```dart
Map<String, dynamic> _userStats = {
  'todayExpenseCount': int,           // # expenses logged today
  'todaySpending': double,            // Total spent today
  'todayCategorySpending': Map<String, double>, // By category
  'weeklyDetailedExpenses': int,      // Expenses with descriptions
  'monthlySpending': double,          // Month-to-date total
  'monthlyCategorizedExpenses': int,  // Properly categorized count
  'currentExpenseStreak': int,        // Daily logging streak
  'expensesWithReceipts': int,        // Count with photos
  'averageDailySpending': double,     // 30-day average
};
```

### 3. Point System Integration

#### Point Earning Events

**Basic Actions:**
- Log any expense: 2 points
- Add description: +1 bonus point
- Add receipt photo: +2 bonus points
- Categorize properly: +1 bonus point
- Add location: +1 bonus point

**Streak Bonuses:**
- 7-day streak: 10 bonus points
- 30-day streak: 50 bonus points
- 100-day streak: 200 bonus points

**Challenge Completion:**
- Daily challenge: 5-15 points
- Weekly challenge: 20-50 points  
- Monthly challenge: 75-150 points

#### Point Calculation Logic
```dart
int calculateExpensePoints(Expense expense) {
  int basePoints = 2;  // Base logging points
  
  // Bonus points for quality
  if (expense.description.isNotEmpty) basePoints += 1;
  if (expense.receiptPath != null) basePoints += 2;
  if (expense.location != null) basePoints += 1;
  if (expense.subcategory != null) basePoints += 1;
  
  // Streak multiplier
  int streakDays = getCurrentStreak();
  double multiplier = 1.0 + (streakDays / 100.0); // Max 2x at 100 days
  
  return (basePoints * multiplier).floor();
}
```

### 4. Badge System Integration

#### Expense-Related Badges

**Logging Badges:**
- "Expense Tracker": Log first expense
- "Daily Discipline": 30-day logging streak
- "Master Tracker": 100-day logging streak
- "Legendary Logger": 365-day logging streak

**Quality Badges:**
- "Detail Oriented": 100 expenses with descriptions
- "Receipt Collector": 50 expenses with photos
- "Location Master": 100 expenses with location
- "Category Expert": 500 properly categorized expenses

**Filipino-Themed Badges:**
- "Kuripot Royalty": Stay under budget for 30 days
- "Masinop na Pinoy": Consistent expense tracking
- "Ipon Master": Balance saving with spending tracking

### 5. Level System Integration

#### Experience Calculation
```dart
// Level calculation based on expense activities
int calculateExpenseExperience() {
  int totalExp = 0;
  
  // Base experience from total expenses logged
  totalExp += expenses.length * 5;
  
  // Quality bonuses
  int detailedExpenses = expenses.where((e) => e.description.isNotEmpty).length;
  totalExp += detailedExpenses * 2;
  
  int expensesWithReceipts = expenses.where((e) => e.receiptPath != null).length;
  totalExp += expensesWithReceipts * 3;
  
  // Streak bonuses
  int currentStreak = getCurrentExpenseStreak();
  totalExp += currentStreak * 10;
  
  return totalExp;
}
```

**Level Thresholds:**
- Level 1: 0-99 XP
- Level 2: 100-299 XP  
- Level 3: 300-599 XP
- Level 4: 600-999 XP
- Level 5+: +500 XP per level

## Analytics & Insights

### 1. Time-Based Analytics

#### Daily Analytics
```dart
double get todaySpending => _expenses
  .where((e) => _isSameDay(e.dateTime, DateTime.now()))
  .fold(0.0, (sum, e) => sum + e.amount);

Map<String, double> get todayByCategory => _groupExpensesByCategory(
  _expenses.where((e) => _isSameDay(e.dateTime, DateTime.now()))
);
```

#### Monthly Analytics
```dart
double get monthlySpending => _expenses
  .where((e) => _isSameMonth(e.dateTime, DateTime.now()))
  .fold(0.0, (sum, e) => sum + e.amount);

List<double> get dailySpendingThisMonth => _calculateDailyTotals(
  DateTime.now().year, DateTime.now().month
);
```

#### Yearly Analytics
```dart
Map<int, double> get monthlyTotalsThisYear => _calculateMonthlyTotals(
  DateTime.now().year
);

List<Expense> get topExpensesThisYear => _expenses
  .where((e) => e.dateTime.year == DateTime.now().year)
  .toList()..sort((a, b) => b.amount.compareTo(a.amount));
```

### 2. Category Analytics

#### Category Distribution
```dart
Map<String, double> get expensesByCategory {
  final Map<String, double> categoryTotals = {};
  
  for (final expense in _expenses) {
    categoryTotals[expense.category] = 
      (categoryTotals[expense.category] ?? 0) + expense.amount;
  }
  
  return categoryTotals;
}
```

#### Subcategory Breakdown
```dart
Map<String, Map<String, double>> get subcategoryBreakdown {
  final breakdown = <String, Map<String, double>>{};
  
  for (final expense in _expenses) {
    breakdown.putIfAbsent(expense.category, () => {});
    breakdown[expense.category]![expense.subcategory ?? 'Other'] = 
      (breakdown[expense.category]![expense.subcategory ?? 'Other'] ?? 0) + 
      expense.amount;
  }
  
  return breakdown;
}
```

### 3. Behavioral Analytics

#### Spending Patterns
```dart
// Average spending by day of week
Map<int, double> get averageSpendingByWeekday {
  final weekdayTotals = <int, List<double>>{};
  
  for (final expense in _expenses) {
    weekdayTotals.putIfAbsent(expense.dateTime.weekday, () => []);
    weekdayTotals[expense.dateTime.weekday]!.add(expense.amount);
  }
  
  return weekdayTotals.map((weekday, amounts) => 
    MapEntry(weekday, amounts.isEmpty ? 0.0 : 
      amounts.reduce((a, b) => a + b) / amounts.length)
  );
}
```

#### Streak Analytics
```dart
class StreakAnalytics {
  static int longestStreak = 0;
  static int currentStreak = 0;
  static DateTime? lastLoggedDate;
  static Map<String, int> categoryStreaks = {};
}
```

## Performance Characteristics

### 1. Data Access Patterns

**Read Performance:**
- Expenses loaded once on app start
- Cached in memory via ExpenseProvider
- Sorted list maintained: O(1) for recent expenses
- Date-range queries: O(n) linear scan
- Category grouping: O(n) single pass

**Write Performance:**
- Insert at beginning: O(1) with maintained sort
- Update by ID: O(n) lookup + O(1) replace
- Delete by ID: O(n) lookup + O(1) remove
- Bulk operations: Batched for efficiency

### 2. Memory Management

**Memory Footprint:**
- ~1000 expenses ≈ 200KB in memory
- Image paths stored, images loaded on-demand
- Category maps cached for quick lookup
- Analytics computed on-demand, not cached

**Optimization Strategies:**
- Lazy loading for old expenses (>1 year)
- Image compression for receipts
- Pagination for large expense lists
- Background cleanup of unused data

### 3. Database Performance

**Hive Optimizations:**
- Batch writes for multiple expenses
- Lazy box opening for faster startup
- Compact database periodically
- Index-free design (sorted in memory)

## Error Handling & Data Integrity

### 1. Input Validation & Sanitization

```dart
class ExpenseValidator {
  static void validateAmount(double amount) {
    if (amount <= 0) throw ValidationException('Amount must be positive');
    if (amount > 999999999) throw ValidationException('Amount too large');
  }
  
  static void validateDescription(String description) {
    if (description.trim().isEmpty) {
      throw ValidationException('Description required');
    }
    if (description.length > 500) {
      throw ValidationException('Description too long');
    }
  }
  
  static void validateDate(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now.add(Duration(hours: 1)))) {
      throw ValidationException('Future dates not allowed');
    }
    if (date.isBefore(DateTime(2000))) {
      throw ValidationException('Date too far in past');
    }
  }
}
```

### 2. Database Error Handling

```dart
Future<void> addExpense(Expense expense) async {
  try {
    // Validate before database operation
    ExpenseValidator.validateAmount(expense.amount);
    ExpenseValidator.validateDescription(expense.description);
    ExpenseValidator.validateDate(expense.dateTime);
    
    await DatabaseService.addExpense(expense);
    _expenses.insert(0, expense);
    notifyListeners();
    
    // Notify other systems
    challengeProvider.onExpenseAdded();
    
  } catch (ValidationException e) {
    // User-facing validation error
    throw e;
  } catch (e) {
    // Database or system error
    debugPrint('Error adding expense: $e');
    throw DatabaseException('Failed to save expense');
  }
}
```

### 3. Data Recovery & Backup

**Backup Strategy:**
- Local JSON export functionality
- Manual data export/import
- No automatic cloud backup (privacy-first)

**Recovery Procedures:**
- Hive database corruption handling
- Partial data recovery from corrupted files
- Fresh start option with data migration

## Security & Privacy

### 1. Data Privacy

**Local-First Architecture:**
- All expense data stored locally
- No automatic cloud synchronization
- User controls all data sharing
- Optional manual export/import

**PII Handling:**
- Descriptions may contain sensitive info
- Receipt photos stored locally
- Location data optional and user-controlled
- No telemetry or analytics transmission

### 2. Input Security

**Sanitization:**
- HTML/XSS prevention in text fields
- File path validation for receipts
- Amount parsing security
- SQL injection N/A (NoSQL storage)

**Validation Security:**
- Server-side validation equivalent on client
- Type safety via Dart strong typing
- Range checks for all numeric inputs

## Future Enhancement Opportunities

### 1. Advanced Analytics

**Predictive Features:**
- Monthly spending predictions
- Budget overrun warnings
- Category spending trends
- Unusual expense detection

**Machine Learning:**
- Automatic category suggestion
- Receipt OCR for amount/merchant extraction
- Spending pattern analysis
- Personalized saving recommendations

### 2. User Experience Improvements

**Smart Input:**
- Voice-to-text for descriptions
- Quick add templates for common expenses
- Bulk expense import
- Smart notifications for expense logging

**Visualization:**
- Interactive spending charts
- Category trend analysis
- Budget vs actual comparisons
- Streak visualization

### 3. Integration Enhancements

**External Integrations:**
- Bank account synchronization
- E-wallet integration
- QR code receipt scanning
- GPS-based location detection

**Social Features:**
- Family expense sharing
- Group challenges
- Spending leaderboards
- Community insights

## API Reference

### ExpenseProvider Methods

```dart
// Core CRUD operations
Future<void> loadExpenses()                     // Load from database
Future<void> addExpense(Expense expense)        // Create new expense
Future<void> updateExpense(Expense expense)     // Update existing expense
Future<void> deleteExpense(String id)          // Delete by ID

// Analytics getters
double get totalExpensesThisMonth              // Current month total
double get totalExpensesToday                  // Today's total
Map<String, double> get expensesByCategory     // Category breakdown
List<Expense> getExpensesForDateRange(start, end) // Date range query

// State getters
List<Expense> get expenses                     // All expenses (sorted)
bool get isLoading                            // Loading state
```

### Expense Model Methods

```dart
// Utilities
Expense copyWith({...})                       // Immutable updates
Map<String, dynamic> toMap()                  // Serialization
factory Expense.fromMap(Map<String, dynamic> map) // Deserialization

// Validation (static methods)
static void validateAmount(double amount)     // Amount validation
static void validateDescription(String desc) // Description validation
static void validateDate(DateTime date)      // Date validation
```

### Integration Points

```dart
// Challenge system notifications
challengeProvider.onExpenseAdded()           // New expense added
challengeProvider.onExpenseUpdated()         // Expense modified
challengeProvider.onExpenseDeleted()         // Expense removed

// Streak system updates
streakService.updateExpenseStreak()          // Recalculate streak
streakService.checkMilestones()              // Check for celebrations

// Analytics updates
analyticsService.updateSpendingStats()       // Refresh analytics
analyticsService.updateCategoryTrends()      // Update category analysis
```

---

*This documentation reflects the current implementation as of the latest build. For implementation details, refer to the source code in the respective directories.*
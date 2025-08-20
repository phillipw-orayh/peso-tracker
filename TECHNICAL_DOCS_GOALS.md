# PesoTracker Goals System - Technical Documentation

## Executive Summary

The Goals System in PesoTracker is a comprehensive savings goal management system that enables Filipino users to set, track, and achieve financial objectives. The system integrates deeply with the gamification engine, streak tracking, and challenge system to provide a motivating user experience.

## Core Architecture

### 1. Data Models

#### SavingsGoal Model (`lib/shared/models/savings_goal.dart`)

**Primary Structure:**
```dart
@HiveType(typeId: 2)
class SavingsGoal extends HiveObject {
  @HiveField(0) String id;              // Unique identifier
  @HiveField(1) String title;           // User-defined goal name
  @HiveField(2) String description;     // Detailed description
  @HiveField(3) double targetAmount;    // Target peso amount
  @HiveField(4) double currentAmount;   // Current saved amount
  @HiveField(5) DateTime createdDate;   // Goal creation timestamp
  @HiveField(6) DateTime targetDate;    // Target completion date
  @HiveField(7) GoalType type;          // Short/Medium/Long term
  @HiveField(8) String? iconPath;       // Optional custom icon
  @HiveField(9) bool isCompleted;       // Completion status
  @HiveField(10) DateTime? completedDate; // Completion timestamp
}
```

**Goal Types:**
```dart
@HiveType(typeId: 1)
enum GoalType {
  @HiveField(0) shortTerm,    // < 1 year goals
  @HiveField(1) mediumTerm,   // 1-3 year goals  
  @HiveField(2) longTerm      // 3+ year goals
}
```

#### Computed Properties

**Progress Calculations:**
- `progressPercentage`: `(currentAmount / targetAmount * 100).clamp(0, 100)`
- `remainingAmount`: `(targetAmount - currentAmount).clamp(0, targetAmount)`
- `daysRemaining`: Calculated from `targetDate.difference(DateTime.now()).inDays`
- `dailySavingsNeeded`: `remainingAmount / daysRemaining` (for planning)

**Alias Properties:**
- `savedAmount`: Getter/setter alias for `currentAmount` (UI consistency)

### 2. State Management - GoalProvider

#### Core State Variables
```dart
class GoalProvider extends ChangeNotifier {
  List<SavingsGoal> _goals = [];           // All goals
  bool _isLoading = false;                 // Loading state
  BuildContext? _context;                  // For celebrations
}
```

#### Computed Getters
- `activeGoals`: Non-completed goals only
- `completedGoals`: Completed goals only
- `totalSavingsGoalAmount`: Sum of all active goal targets
- `totalCurrentSavings`: Sum of all active goal progress
- `totalSavingsProgress`: Overall progress percentage

### 3. Database Integration

#### Hive Storage Configuration
- **TypeId**: 2 (SavingsGoal), 1 (GoalType)
- **Storage Location**: Local device storage via Hive
- **Persistence**: Automatic via HiveObject extension
- **Data Format**: Binary (Hive native)

#### CRUD Operations
```dart
// Create
await DatabaseService.addGoal(goal);

// Read
List<SavingsGoal> goals = DatabaseService.getAllGoals();

// Update
await DatabaseService.updateGoal(goal);

// Delete
await DatabaseService.deleteGoal(id);
```

## Goal Lifecycle Management

### 1. Goal Creation Process

**User Flow:**
1. User navigates to Add Goal screen (`/add-goal`)
2. Fills goal form with:
   - Title and description
   - Target amount (peso validation)
   - Target date (date picker)
   - Goal type selection
   - Optional icon selection
3. Goal validation occurs client-side
4. Goal saved to Hive database
5. GoalProvider state updated
6. User redirected to goals list

**Validation Rules:**
- Title: Required, 1-100 characters
- Target amount: > 0, < 999,999,999 pesos
- Target date: Must be future date
- Description: Optional, max 500 characters

### 2. Goal Progress Tracking

**Manual Updates:**
- User can update `currentAmount` through Edit Goal screen
- Progress automatically recalculated on save
- Visual progress bars update in real-time

**Automatic Completion Detection:**
```dart
// Goal completion logic
if (goal.currentAmount >= goal.targetAmount && !goal.isCompleted) {
  goal.isCompleted = true;
  goal.completedDate = DateTime.now();
  // Trigger celebration
  CelebrationService.celebrateGoalAchieved(context, goalTitle, amount);
}
```

### 3. Goal Editing & Updates

**Editable Fields:**
- Title, description
- Target amount (can increase/decrease)
- Target date (can extend)
- Current amount/progress
- Goal type (reclassification)

**Update Process:**
1. GoalProvider.updateGoal() called
2. Old goal state cached for comparison
3. Database updated via DatabaseService
4. Provider state synchronized
5. Celebration triggered if newly completed
6. UI notified via ChangeNotifier

## Integration with Gamification System

### 1. Challenge System Integration

**Goal-Related Challenges:**
```dart
// Example challenges that track goal behavior
'monthly_saver': {
  'action': 'goal_contribution',
  'amount': 1000.0,  // Monthly contribution target
  'timeframe': 'monthly'
}

'goal_achiever': {
  'action': 'complete_goal',
  'count': 1,  // Complete any goal
  'timeframe': 'all_time'
}
```

**Stats Tracked by ChallengeProvider:**
- `weeklyGoalSavings`: Estimated weekly contributions
- `completedGoalsThisMonth`: Monthly completion count
- `todayGoalContributions`: Daily savings added
- `monthlySavings`: Total savings across all goals

### 2. Point System Integration

**Point Earning Events:**
- Goal creation: 5 points
- Goal milestone (25%, 50%, 75%): 10 points each
- Goal completion: 50 points + bonus based on goal size
- Streak maintenance: 5 points per week

**Calculation Logic:**
```dart
// Goal completion points
int basePoints = 50;
int bonusPoints = (goal.targetAmount / 1000).floor(); // 1 point per ₱1000
int totalPoints = basePoints + bonusPoints.clamp(0, 100); // Max 150 points
```

### 3. Badge System Integration

**Goal-Related Badges:**
- "Goal Crusher": Complete any goal
- "Ipon Master": Save specific amount monthly
- "Financial Planner": Create 5+ goals
- "Streak Saver": Maintain goal contributions for 30 days

### 4. Level System Integration

**Experience Calculation:**
- Level = totalPoints / 100
- Each level requires 100 additional points
- Goals contribute significantly to level progression

## Streak System Integration

### 1. Goal-Related Streaks

**Streak Types:**
1. **Savings Streak**: Daily goal contributions
2. **Planning Streak**: Regular goal reviews/updates
3. **Completion Streak**: Achieving goals on schedule

### 2. Streak Calculation Logic

**Current Implementation:**
```dart
// Expense-based streak (affects goal recommendations)
int currentStreak = 0;
DateTime checkDate = today;

for (int i = 0; i < 365; i++) {
  final dayExpenses = expenses.where((e) => _isSameDay(e.dateTime, checkDate));
  if (dayExpenses.isNotEmpty) {
    currentStreak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  } else {
    break;
  }
}
```

**Goal Impact on Streaks:**
- Goal contributions can maintain financial discipline streak
- Goal completions reset or extend positive streaks
- Goal updates count as financial engagement

### 3. Streak Rewards & Motivation

**Milestone Celebrations:**
- 7-day streak: Encouragement notification
- 30-day streak: Badge + confetti celebration
- 100-day streak: Special achievement unlock

## Performance Characteristics

### 1. Data Access Patterns

**Read Operations:**
- Goals loaded once on app start
- Cached in memory via GoalProvider
- Real-time calculations use cached data
- Database queries only on CRUD operations

**Write Operations:**
- Batched updates where possible
- Immediate UI feedback with optimistic updates
- Background database persistence

### 2. Memory Usage

**Typical Memory Footprint:**
- ~50 goals = ~25KB in memory
- Hive database file: ~100KB for 1000 goals
- Image assets cached separately

### 3. Performance Optimizations

**List Rendering:**
- Sorted once on load: `goals.sort((a, b) => a.targetDate.compareTo(b.targetDate))`
- Filtered lists computed on-demand
- ListView.builder for large lists

**State Updates:**
- Granular notifyListeners() calls
- Computed properties cached where possible
- Minimal widget rebuilds via Consumer widgets

## Error Handling & Resilience

### 1. Database Error Handling

```dart
Future<void> addGoal(SavingsGoal goal) async {
  try {
    await DatabaseService.addGoal(goal);
    _goals.add(goal);
    notifyListeners();
  } catch (e) {
    debugPrint('Error adding goal: $e');
    rethrow;  // Let UI handle user-facing errors
  }
}
```

### 2. Data Validation

**Input Validation:**
- Amount formatting validation
- Date boundary checking
- String length limits
- Required field validation

**Data Integrity:**
- Hive type safety
- Null safety throughout
- Default value fallbacks

### 3. Migration Strategy

**Schema Evolution:**
- Hive handles backward compatibility
- New fields added with default values
- Migration logic for major changes

## Security Considerations

### 1. Data Privacy

**Local Storage:**
- All goal data stored locally on device
- No cloud synchronization (privacy by design)
- Hive encryption possible for sensitive data

**PII Handling:**
- Goal titles/descriptions may contain personal info
- No automatic data transmission
- User controls all data export/import

### 2. Input Sanitization

**User Input Validation:**
- XSS prevention in text fields
- Number format validation
- Date parsing security

## Future Enhancement Opportunities

### 1. Advanced Features

**Smart Recommendations:**
- AI-powered goal suggestions based on expense patterns
- Automatic savings amount recommendations
- Deadline optimization based on income patterns

**Social Features:**
- Goal sharing (privacy-controlled)
- Family/group goals
- Community challenges

### 2. Technical Improvements

**Performance:**
- Background goal progress calculation
- Predictive data loading
- Enhanced caching strategies

**User Experience:**
- Goal templates/presets
- Photo/video goal tracking
- Voice note attachments
- Offline-first synchronization

### 3. Analytics Integration

**Goal Success Metrics:**
- Completion rate tracking
- Average time to completion
- Success factors analysis
- User behavior insights

## API Reference

### GoalProvider Methods

```dart
// Core CRUD operations
Future<void> loadGoals()                    // Load from database
Future<void> addGoal(SavingsGoal goal)      // Create new goal
Future<void> updateGoal(SavingsGoal goal)   // Update existing goal
Future<void> deleteGoal(String id)         // Delete by ID

// State management
void setContext(BuildContext context)      // Set celebration context

// Getters
List<SavingsGoal> get goals                // All goals
List<SavingsGoal> get activeGoals          // Non-completed goals
List<SavingsGoal> get completedGoals       // Completed goals
double get totalSavingsGoalAmount          // Sum of target amounts
double get totalCurrentSavings             // Sum of current amounts
double get totalSavingsProgress            // Overall progress %
bool get isLoading                         // Loading state
```

### SavingsGoal Methods

```dart
// Computed properties
double get progressPercentage              // 0-100% completion
double get remainingAmount                 // Amount left to save
int get daysRemaining                      // Days until target date
double get dailySavingsNeeded              // Required daily savings

// Utilities
SavingsGoal copyWith({...})                // Immutable updates
Map<String, dynamic> toMap()               // Serialization
factory SavingsGoal.fromMap(Map<String, dynamic> map) // Deserialization
```

---

*This documentation reflects the current implementation as of the latest build. For implementation details, refer to the source code in the respective directories.*
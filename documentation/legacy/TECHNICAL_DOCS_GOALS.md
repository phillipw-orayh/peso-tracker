# IponGPT Goals System - Technical Documentation

## Executive Summary

The Goals System in IponGPT is a comprehensive savings goal management system that enables Filipino users to set, track, and achieve financial objectives. The system integrates deeply with the gamification engine, streak tracking, and challenge system to provide a motivating user experience.

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

The goals system integrates with gamification features including challenges, points, badges, streaks, and level progression. Current implementation includes basic goal completion tracking and celebration triggers. Comprehensive gamification system design is documented in TECHNICAL_IMPLEMENTATION_GUIDE.md with Filipino-centric approach.

## Performance Characteristics

The goals system uses in-memory caching with Hive persistence for optimal performance. Data is loaded once on app start and cached for real-time calculations. Actual performance strategies are specified in BACKEND_IMPLEMENTATION_DETAILS.md.

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


## API Reference

Core API includes GoalProvider CRUD operations, computed getters for analytics, and SavingsGoal utility methods. Detailed API documentation is maintained in code comments and will be updated during Riverpod migration.

---

*This documentation reflects the current implementation as of the latest build. For implementation details, refer to the source code in the respective directories.*
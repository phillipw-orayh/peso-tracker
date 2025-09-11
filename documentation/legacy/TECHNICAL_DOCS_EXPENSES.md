# IponGPT Expense System - Technical Documentation

## Executive Summary

The Expense System in IponGPT is the core financial tracking component that enables Filipino users to record, categorize, and analyze their spending patterns. This system serves as the foundation for streak tracking, challenge completion, and financial insights within the gamification framework.

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

The expense system integrates with the gamification features including streaks, challenges, points, badges, and level progression. Current implementation includes basic streak tracking and challenge progress monitoring. Detailed gamification specifications are documented in TECHNICAL_IMPLEMENTATION_GUIDE.md and BACKEND_IMPLEMENTATION_DETAILS.md.

## Analytics & Insights

Basic analytics include time-based totals, category breakdowns, and spending patterns. Current implementation provides foundational analytics with basic computed properties. Advanced analytics features are specified in the Reports/Analytics screen in TECHNICAL_IMPLEMENTATION_GUIDE.md.

## Performance Characteristics

The expense system uses in-memory caching with Hive persistence for optimal performance. Current implementation handles typical user loads efficiently. Detailed performance optimization strategies are documented in BACKEND_IMPLEMENTATION_DETAILS.md.

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


## API Reference

Core API includes ExpenseProvider CRUD operations, computed analytics getters, and integration points with gamification systems. Detailed API documentation is maintained in code comments and will be updated during Riverpod migration.

---

*This documentation reflects the current implementation as of the latest build. For implementation details, refer to the source code in the respective directories.*
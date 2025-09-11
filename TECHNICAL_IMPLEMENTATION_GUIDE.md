# IponGPT Technical Implementation Guide

## Overview
This document provides detailed technical implementation steps for transforming PesoTracker into IponGPT, organized by Front End (UI screens) and Back End (technical infrastructure) components.

---

# FRONT END

## 1. Home Screen (HomeScreen)

### Current Layout:
![Home Screen Current Layout](old%20layout/HomeScreen.png)

### Current Features:
- Basic greeting with user name ("Kumusta, Phill!")
- Current Streak card with flame icon showing 0 days and best streak
- Gastos Summary section with Today/This Month totals (₱0.00)
- Top Categories breakdown (Bills: ₱556.00, Food: ₱500.00)
- Savings Goals preview with "Walang savings goals pa" message
- Bottom navigation with Home, Mga Gastos, Goals, Hamon tabs
- Green floating "+" button for adding new items
- Settings gear icon in top right

### Proposed UI Changes:
- **Add prominent "+" button in center** for quick Money In/Money Out entry
- **Multiple wallet selector** at top (Cash, Card, VPS, etc.) with balance display
- **Enhanced streak visualization** with flame animations and confetti
- **Total balance display** prominently at top with hide/show toggle
- **Money Insider section** showing visual spending trends with mini charts
- **AI Coach floating icon** for quick access to financial advisor
- **Cultural motivational phrases** below sections ("Konting tiis, Josh! Ipon na malapit na!")
- **Enhanced visual design** with thermometer-style progress bars
- **Quick action cards** for common tasks (Add Expense, Check Goals, View Challenges)

### Implementation Details:
```dart
// New wallet selector widget
class WalletSelector extends StatelessWidget {
  final List<Wallet> wallets;
  final Wallet selectedWallet;
  final Function(Wallet) onWalletChanged;
  
  // Displays horizontal scrolling wallet cards
  // Shows balance for each wallet
  // Allows quick switching between wallets
}

// Enhanced streak visualization
class EnhancedStreakCard extends StatefulWidget {
  // Animated flame icons
  // Confetti animation on streak milestones
  // Best streak tracking display
  // Progress towards next milestone
}

// Money Insider mini charts
class SpendingTrendsWidget extends StatelessWidget {
  // Mini pie chart for category breakdown
  // Weekly spending line graph
  // Comparison with previous period
}
```

---

## 2. Add Expense Screen (AddExpenseScreen)

### Current Features:
- Amount input field
- Category dropdown selection
- Subcategory selection
- Description text field
- Date picker
- Form validation
- Basic expense creation

### Proposed UI Changes:
- **Unified Money In/Money Out tabs** in single screen
- **Voice input button** with "Nag-spend ako ng ₱50 sa breakfast" support
- **Photo receipt capture** button with auto-categorization preview
- **Filipino-specific categories**:
  - Pagkain, Transportasyon (Jeep/Bus/MRT/LRT/Trike)
  - Bills (Kuryente/Tubig/Internet/Load)
  - Shopping (Grocery, Damit)
  - Entertainment (Movies, Gimik, Inuman)
- **Recurring transaction toggle** with frequency options
- **Location-based hints** (optional) for common places
- **Quick amount buttons** (₱20, ₱50, ₱100, ₱200)
- **Recent transactions suggestions** for faster entry
- **Wallet selection** integrated into the form

### Implementation Details:
```dart
class UnifiedTransactionEntry extends StatefulWidget {
  // TabBar for Money In/Money Out
  // Voice recognition integration
  // Camera integration for receipt capture
  // ML-based category suggestion from photos
}

class VoiceInputWidget extends StatefulWidget {
  // Speech-to-text integration
  // Natural language processing for Filipino phrases
  // Automatic amount and category extraction
}

class PhotoReceiptCapture extends StatefulWidget {
  // Camera integration
  // OCR for text extraction from receipts
  // Smart category suggestion based on merchant
}
```

---

## 3. Expense List Screen (ExpenseListScreen)

### Current Layout:
![Expense List Screen Current Layout](old%20layout/Expenses.png)

### Current Features:
- "Mga Gastos" title with settings icon
- Search bar with "Search expenses..." placeholder
- Category filter tabs (All, Pagkain, Transportasyon, Bills)
- Expense cards showing:
  - Category icons (Bills with calendar icon, Food with utensils icon)
  - Expense description and category type
  - Amount in green (₱556.00, ₱500.00)
  - Date timestamps (Aug 22, 2025, Aug 20, 2025)
- Green floating "+" button for adding expenses
- Bottom navigation

### Proposed UI Changes:
- **Visual category icons** instead of text labels
- **Enhanced expense cards** with merchant logos/icons
- **Swipe actions** for quick edit/delete/duplicate
- **Advanced filtering** by category, date range, amount
- **Search functionality** with smart suggestions
- **Visual spending patterns** with mini charts per category
- **Bulk operations** (select multiple, bulk delete/edit)
- **Receipt photos** displayed as thumbnails on cards
- **Quick stats bar** showing total, average, highest expense

### Implementation Details:
```dart
class EnhancedExpenseCard extends StatelessWidget {
  // Category icons and colors
  // Receipt photo thumbnails
  // Swipe action buttons
  // Visual amount highlighting
}

class ExpenseFilterSheet extends StatefulWidget {
  // Date range picker
  // Category multi-select
  // Amount range slider
  // Saved filter presets
}
```

---

## 4. Goals Screen (GoalsScreen)

### Current Layout:
![Goals Screen Current Layout](old%20layout/Goals.png)

### Current Features:
- "My Goals" title with settings icon
- Goal duration tabs (All, Short, Medium, Long)
- Goal Statistics card with empty state message
- "No goals yet" placeholder with folder icon
- "Create your first goal to see statistics here" instruction
- "Walang savings goals pa" message at bottom
- "Create First Goal" text
- Green "+ create goal" button at bottom
- Green floating flag icon button
- Bottom navigation with Goals tab highlighted

### Proposed UI Changes:
- **Goal templates** with preset options (Phone, Baguio trip, emergency fund, tuition)
- **Thermometer-style progress bars** with milestone animations
- **Visual progress indicators** with confetti on achievements
- **Social sharing buttons** ("I'm 50% closer to my Siargao trip!")
- **Timeline calculators** showing projected completion dates
- **Goal categories** with different visual themes
- **Quick contribute button** for easy progress updates
- **Achievement badges** for completed goals
- **Progress photos** option to add visual motivation

### Implementation Details:
```dart
class ThermometerProgressBar extends StatefulWidget {
  // Animated filling effect
  // Milestone markers
  // Confetti animation on milestones
}

class GoalTemplateSelector extends StatelessWidget {
  // Predefined goal templates
  // Visual template cards
  // Smart default amounts and timelines
}

class SocialShareButton extends StatelessWidget {
  // Integration with social platforms
  // Custom share images
  // Progress celebration messages
}
```

---

## 5. Add/Edit Goal Screen (AddGoalScreen, EditGoalScreen)

### Current Features:
- Goal name input
- Target amount input
- Target date picker
- Goal type selection
- Basic form validation

### Proposed UI Changes:
- **Visual goal type selection** with icons and descriptions
- **Smart amount suggestions** based on goal type
- **Timeline calculator** showing required daily/weekly savings
- **Visual progress preview** of what the completed goal will look like
- **Motivation image upload** for personal goal visualization
- **Sub-goals creation** for large goals broken into milestones
- **Reminder notifications** setup for regular contributions

### Implementation Details:
```dart
class GoalTypeSelector extends StatelessWidget {
  // Visual grid of goal types
  // Icons and descriptions
  // Smart defaults for each type
}

class TimelineCalculator extends StatefulWidget {
  // Interactive calculations
  // Visual timeline display
  // Adjustment sliders for flexibility
}
```

---

## 6. Challenges/Gamification Screen (ChallengesScreen, BadgesScreen)

### Current Layout:
![Challenges Screen Current Layout](old%20layout/Challenges.png)

### Current Features:
- "Mga Hamon" (Challenges) title with settings icon
- Challenge period tabs (Overview, Daily, Weekly, Monthly)
- Your Challenge Stats section with colored stat cards:
  - Points: 0 (yellow with star icon)
  - Active: 0 (green with info icon)
  - Done: 0 (green with checkmark icon)
  - Badges: 0 (red with badge icon)
  - Streak: 0 days (red with flame icon)
  - Level: 1 (purple with trend icon)
- Level progress bar showing "Level 1" and "100 points to Level 2"
- Active Challenges section with empty state
- "No active challenges" message with folder icon
- Instructions to "Swipe right to choose new challenges in Daily, Weekly, or Monthly tabs"
- Earned Badges section with "View All" link
- Bottom navigation with Hamon (trophy icon) tab highlighted

### Proposed UI Changes:
- **Enhanced challenge cards** with Filipino-themed designs
- **Passive challenge tracking** with automatic enrollment
- **Challenge types**:
  - Tipid Tuesday, No Kape, Baon Lang
  - Jeepney Mode, Week-long Saver
  - Receipt Warrior, Masinop na Pinoy, Ipon Master
- **Community leaderboards** (Barangay/barkada/family competitions)
- **Visual progress tracking** with animated progress bars
- **Achievement celebrations** with confetti and sound effects
- **Challenge history** showing completed challenges
- **Social features** for sharing achievements

### Implementation Details:
```dart
class FilipinoChallengeCard extends StatefulWidget {
  // Cultural theming and colors
  // Progress animations
  // Community ranking display
}

class LeaderboardWidget extends StatelessWidget {
  // Community rankings
  // Friend/family comparisons
  // Achievement showcases
}
```

---

## 7. Settings Screen (SettingsScreen)

### Current Layout:
![Settings Screen Current Layout](old%20layout/Settings.png)

### Current Features:
- "Settings" title with back arrow and home icon
- User profile card showing:
  - User avatar ("P" in green circle)
  - Name ("Phill") with "Current" badge
  - Level and streak ("Level 1 • 0 day streak")
  - Monthly Income ("Monthly Income: ₱8000")
  - Three-dot menu option
- Account section with:
  - Profile option ("Name, avatar, preferences")
  - User Management ("Manage local users / accounts")
- App section with:
  - Language setting ("Filipino / English")
  - Theme setting ("System default")
  - Notifications toggle (enabled - green switch)
- Data section with:
  - Export data option
  - Import data option
  - Clear all local data (in red text)

### Proposed UI Changes:
- **Enhanced privacy controls** with clear explanations
- **Security settings** (biometric/PIN setup)
- **Notification preferences** with granular controls
- **Data management** (export, backup, delete options)
- **Premium upgrade** section with feature comparisons
- **AI Coach settings** (personality, language preference)
- **Wallet management** for multiple accounts
- **Cultural preferences** (Taglish level, regional dialects)

### Implementation Details:
```dart
class PrivacyControlPanel extends StatefulWidget {
  // Toggle switches for each privacy setting
  // Clear explanations of data usage
  // Easy export/delete options
}

class SecuritySetupScreen extends StatefulWidget {
  // Biometric authentication setup
  // PIN creation and confirmation
  // Security level indicators
}
```

---

## 8. AI Coach Chat Screen (New)

### Current Features:
- Not implemented

### Proposed UI Changes:
- **Chat interface** with conversational AI
- **Quick action chips** for common questions
- **Taglish support** with language mixing
- **Contextual advice** based on spending patterns
- **Visual insights** with charts and graphs in chat
- **Voice interaction** option for hands-free use
- **Smart suggestions** based on financial behavior
- **Educational content** delivery through conversations

### Implementation Details:
```dart
class AICoachChatScreen extends StatefulWidget {
  // Chat bubble UI
  // Quick action buttons
  // Voice input/output integration
  // Contextual response generation
}

class ChatBubble extends StatelessWidget {
  // Different styles for user/AI messages
  // Rich content support (charts, images)
  // Timestamp and status indicators
}

class QuickActionChips extends StatelessWidget {
  // Predefined question buttons
  // Context-aware suggestions
  // Popular query shortcuts
}
```

---

## 9. Reports/Analytics Screen (New)

### Current Features:
- Basic expense summaries

### Proposed UI Changes:
- **Visual charts** (pie/bar/line charts for categories)
- **Trend analysis** with time period comparisons
- **Story-style recaps** with Filipino context
- **Spending pattern insights** with recommendations
- **Goal progress analytics** with projections
- **Export options** (CSV, PDF for premium users)
- **Comparative analysis** (month-over-month, year-over-year)

### Implementation Details:
```dart
class InteractiveChartWidget extends StatefulWidget {
  // Multiple chart types
  // Touch interactions
  // Drill-down capabilities
}

class SpendingInsightsCard extends StatelessWidget {
  // AI-generated insights
  // Actionable recommendations
  // Cultural context integration
}
```

---

# BACK END

## 1. State Management Migration (Provider → Riverpod)

### Current Implementation:
- Using Provider package for state management
- ChangeNotifier-based providers
- BuildContext-dependent state access
- Manual provider disposal

### Migration Requirements:

#### Dependencies Update:
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
dev_dependencies:
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.7
  riverpod_lint: ^2.3.7
```

#### Provider Migration Pattern:
```dart
// BEFORE: Provider
class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  
  List<Expense> get expenses => _expenses;
  
  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }
}

// AFTER: Riverpod
@riverpod
class ExpenseNotifier extends _$ExpenseNotifier {
  @override
  List<Expense> build() {
    return _loadExpensesFromDatabase();
  }
  
  void addExpense(Expense expense) {
    state = [...state, expense];
    _saveToDatabase(expense);
  }
}

// Computed providers for derived state
@riverpod
double totalExpenses(TotalExpensesRef ref) {
  final expenses = ref.watch(expenseNotifierProvider);
  return expenses.fold(0, (sum, expense) => sum + expense.amount);
}
```

#### Migration Strategy:
1. **Phase 1**: Add Riverpod dependencies
2. **Phase 2**: Create Riverpod providers alongside existing Provider code
3. **Phase 3**: Update widgets to use ConsumerWidget/ConsumerStatefulWidget
4. **Phase 4**: Test each migrated feature thoroughly
5. **Phase 5**: Remove old Provider code after successful migration

---

## 2. AI Financial Coach Service

### Architecture Design:
```dart
abstract class AICoachService {
  Future<String> getFinancialAdvice(UserFinancialContext context);
  Future<String> generateInsight(List<Expense> expenses);
  Future<List<String>> getSavingsTips(SavingsGoal goal);
  Stream<String> getDailyNudge();
}

// MVP Implementation
class RuleBasedCoachService implements AICoachService {
  // Rule-based system for initial release
}

// Future Implementation
class CloudAICoachService implements AICoachService {
  // Cloud-based AI integration (Gemini, Claude API, etc.)
}
```

### User Financial Context:
```dart
class UserFinancialContext {
  final List<Expense> recentExpenses;
  final List<SavingsGoal> activeGoals;
  final Map<String, double> categorySpending;
  final double monthlyIncome;
  final int currentStreak;
  final List<Challenge> activeChallenges;
  final String preferredLanguage; // 'en', 'tl', 'tl-en' (Taglish)
  
  // Methods for calculating insights
  double get savingsRate => _calculateSavingsRate();
  String get topSpendingCategory => _getTopSpendingCategory();
  double get goalsProgress => _calculateGoalsProgress();
}
```

### Rule Engine Implementation:
```dart
class CoachingRule {
  final bool Function(UserFinancialContext) condition;
  final Map<String, String> advice; // Multi-language support
  final int priority;
}

class RuleBasedCoachService {
  final Map<String, List<CoachingRule>> _rules = {
    'overspending': [
      CoachingRule(
        condition: (context) => 
          context.categorySpending['Food']! > context.monthlyIncome * 0.3,
        advice: {
          'en': 'Your food spending is over 30% of your income. Try meal prepping!',
          'tl-en': 'Uy, halos lahat ng gastos mo nasa food ah! Try cooking at home!',
        },
        priority: 1,
      ),
    ],
    // Additional rule categories...
  };
}
```

---

## 3. Security & Privacy Enhancements

### Biometric/PIN Authentication:
```dart
class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  Future<bool> authenticateUser() async {
    // Biometric authentication with PIN fallback
  }
  
  Future<void> setPIN(String pin) async {
    // Secure PIN storage with hashing
  }
}
```

### Encrypted Local Storage:
```dart
class EncryptedStorageService {
  static Future<Box<T>> openEncryptedBox<T>(String name) async {
    final key = Key.fromBase64(_encryptionKey);
    return await Hive.openBox<T>(
      name,
      encryptionCipher: HiveAesCipher(key.bytes),
    );
  }
}
```

### Privacy Settings Management:
```dart
@riverpod
class PrivacySettings extends _$PrivacySettings {
  @override
  PrivacySettingsState build() {
    return PrivacySettingsState(
      analyticsEnabled: false,
      locationTrackingEnabled: false,
      dataSharingEnabled: false,
      // ... other privacy settings
    );
  }
  
  Future<void> exportUserData() async {
    // Complete data export functionality
  }
  
  Future<void> deleteAllUserData() async {
    // Secure data deletion with confirmation
  }
}
```

---

## 4. Database Enhancements

### Current Database Structure:
- Hive boxes for expenses, goals, user data
- Basic CRUD operations
- No encryption

### Enhanced Database Architecture:
```dart
class DatabaseService {
  // Enhanced box management
  static late Box<Expense> _expenseBox;
  static late Box<SavingsGoal> _goalBox;
  static late Box<UserData> _userBox;
  static late Box<Challenge> _challengeBox; // New
  static late Box<Wallet> _walletBox; // New
  static late Box<AICoachHistory> _coachBox; // New
  static late Box<Subscription> _subscriptionBox; // New
  
  // Enhanced initialization with encryption
  static Future<void> init() async {
    _expenseBox = await EncryptedStorageService.openEncryptedBox<Expense>('expenses');
    _goalBox = await EncryptedStorageService.openEncryptedBox<SavingsGoal>('goals');
    // ... initialize other boxes with encryption
  }
}
```

### New Data Models:
```dart
@HiveType(typeId: 10)
class Wallet extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name; // Cash, Card, GCash, etc.
  
  @HiveField(2)
  double balance;
  
  @HiveField(3)
  String type; // cash, bank, ewallet
  
  @HiveField(4)
  String? accountNumber; // encrypted
}

@HiveType(typeId: 11)
class AICoachHistory extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userMessage;
  
  @HiveField(2)
  String aiResponse;
  
  @HiveField(3)
  DateTime timestamp;
  
  @HiveField(4)
  Map<String, dynamic> context; // Financial context at time of interaction
}
```

---

## 5. Monetization System

### In-App Purchase Integration:
```dart
@riverpod
class SubscriptionService extends _$SubscriptionService {
  static const String monthlyPlanId = 'ipongpt_premium_monthly';
  static const String yearlyPlanId = 'ipongpt_premium_yearly';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  Future<void> purchasePremium(String planId) async {
    // Handle in-app purchase flow
  }
  
  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    // Process purchase verification and feature unlocking
  }
}
```

### Feature Gating System:
```dart
@riverpod
class FeaturesProvider extends _$FeaturesProvider {
  @override
  AppFeatures build() {
    final subscription = ref.watch(subscriptionServiceProvider);
    
    return AppFeatures(
      maxChallenges: subscription.isPremium ? 999 : 3,
      advancedAnalytics: subscription.isPremium,
      familySharing: subscription.isPremium,
      aiCoachPlus: subscription.isPremium,
      multipleWallets: subscription.isPremium,
      // ... other premium features
    );
  }
}

class PremiumFeatureGate extends ConsumerWidget {
  final Widget child;
  final bool Function(AppFeatures) featureCheck;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(featuresProvider);
    
    if (featureCheck(features)) {
      return child;
    }
    
    // Show premium upgrade prompt
    return _buildPremiumPrompt();
  }
}
```

---

## 6. Voice & Photo Processing

### Voice Input Service:
```dart
class VoiceInputService {
  final speech.SpeechToText _speechToText = speech.SpeechToText();
  
  Future<VoiceTransactionData?> processVoiceInput(String audioText) async {
    // Natural language processing for Filipino phrases
    // Extract amount, category, and description
    // Return structured transaction data
  }
  
  Map<String, RegExp> get _filipinoPatterns => {
    'amount': RegExp(r'(\d+)\s*(pesos?|php|₱)?', caseSensitive: false),
    'food': RegExp(r'(pagkain|kain|food|breakfast|lunch|dinner)', caseSensitive: false),
    'transport': RegExp(r'(pamasahe|jeep|bus|mrt|lrt|grab|taxi)', caseSensitive: false),
    // ... other category patterns
  };
}
```

### Photo Receipt Processing:
```dart
class PhotoReceiptService {
  Future<ReceiptData?> processReceiptPhoto(String imagePath) async {
    // OCR text extraction from image
    final extractedText = await _performOCR(imagePath);
    
    // Parse receipt data
    return _parseReceiptText(extractedText);
  }
  
  Future<String> _performOCR(String imagePath) async {
    // Integration with ML Kit or cloud OCR service
  }
  
  ReceiptData _parseReceiptText(String text) {
    // Extract merchant, amount, date, items from receipt text
  }
}
```

---

## 7. Offline-First Architecture

### Sync Service:
```dart
class SyncService {
  Future<void> syncWhenConnected() async {
    if (await _hasInternetConnection()) {
      await _syncExpenses();
      await _syncGoals();
      await _syncUserData();
      await _syncCoachHistory();
    }
  }
  
  Future<void> _syncExpenses() async {
    final unsyncedExpenses = await _getUnsyncedExpenses();
    for (final expense in unsyncedExpenses) {
      try {
        await _uploadExpenseToCloud(expense);
        expense.synced = true;
        await expense.save();
      } catch (e) {
        // Handle sync failure, queue for retry
      }
    }
  }
}
```

### Conflict Resolution:
```dart
class ConflictResolver {
  Future<T> resolveConflict<T>(T localData, T cloudData) async {
    // Implement conflict resolution strategies
    // Last-write-wins, user choice, or merge strategies
  }
}
```

---

## 8. Performance & Optimization

### Image Optimization:
```dart
class ImageOptimizationService {
  Future<File> compressReceiptImage(File image) async {
    // Compress images for storage and upload
    // Maintain quality for OCR while reducing size
  }
}
```

### Database Optimization:
```dart
class DatabaseOptimizationService {
  Future<void> compactDatabase() async {
    // Regular database maintenance
    // Remove old cached data
    // Optimize query performance
  }
  
  Future<void> archiveOldData() async {
    // Archive expenses older than 2 years
    // Maintain aggregated statistics
  }
}
```

---

## Implementation Timeline

### Phase 1 (Weeks 1-3): Foundation & Migration
- Set up Riverpod dependencies
- Begin Provider to Riverpod migration
- Implement basic security features
- Set up encrypted storage

### Phase 2 (Weeks 4-6): Core Features
- Complete state management migration
- Implement AI Coach MVP (rule-based)
- Add voice input functionality
- Enhance home screen UI

### Phase 3 (Weeks 7-9): Advanced Features
- Photo receipt processing
- Multiple wallets support
- Enhanced gamification
- Privacy controls

### Phase 4 (Weeks 10-12): Monetization & Polish
- In-app purchase integration
- Premium features implementation
- Performance optimization
- Comprehensive testing

---

## Testing Strategy

### Unit Tests:
- Provider/Riverpod state management
- Business logic and calculations
- AI Coach rule engine
- Data processing services

### Integration Tests:
- Database operations
- API integrations
- Voice and photo processing
- Sync functionality

### UI Tests:
- Screen navigation flows
- Form validations
- Visual component behavior
- Accessibility compliance

### Performance Tests:
- Database query performance
- Image processing speed
- Memory usage optimization
- Battery consumption monitoring
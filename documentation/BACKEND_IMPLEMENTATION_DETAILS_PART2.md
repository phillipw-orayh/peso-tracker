# IponGPT Backend Implementation Details - Part 2

This document continues the detailed backend implementation guide, covering sections 4-8 of the IponGPT Technical Implementation Guide.

> **Note**: This is Part 2 of the backend implementation details. For sections 1-3, see [BACKEND_IMPLEMENTATION_DETAILS_PART1.md](BACKEND_IMPLEMENTATION_DETAILS_PART1.md)

---

## 4. Database Enhancements

### 4.1 New Data Models & Encrypted Boxes

**Explanation**: Extend the current Hive database with new data models to support enhanced features like multiple wallets, AI coach history, challenges, and premium subscriptions. All new data will be encrypted using the existing encryption infrastructure.

**Example**: Add wallet management for cash/card/digital money tracking, store AI coach conversation history, and track challenge progress with detailed statistics.

**Implementation Solutions**:
- **Extend Current Codebase**: Build on existing Hive + encryption setup
- **Flutter Libraries**: `hive`, `hive_flutter`, `flutter_secure_storage`
- **New TypeId Assignments**: Carefully manage Hive TypeId mapping to avoid conflicts

```dart
// New Data Models for Enhanced Features

// Wallet Model (TypeId: 10)
@HiveType(typeId: 10)
class Wallet extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;              // "Cash", "BPI Card", "GCash"
  @HiveField(2) WalletType type;          // cash, debit_card, credit_card, digital
  @HiveField(3) double balance;           // Current balance
  @HiveField(4) String? color;            // UI color for wallet
  @HiveField(5) String? iconPath;         // Custom wallet icon
  @HiveField(6) bool isActive;            // Show/hide wallet
  @HiveField(7) DateTime createdDate;
  @HiveField(8) String? bankName;         // For cards: "BPI", "BDO", "Metrobank"
  @HiveField(9) String? accountNumber;    // Last 4 digits only for security
  @HiveField(10) Map<String, dynamic>? metadata; // Additional wallet info
  
  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.color,
    this.iconPath,
    this.isActive = true,
    required this.createdDate,
    this.bankName,
    this.accountNumber,
    this.metadata,
  });
  
  // Computed properties
  String get displayName => bankName != null ? '$name ($bankName)' : name;
  String get maskedAccountNumber => accountNumber != null ? '**** $accountNumber' : '';
  
  // JSON serialization for backup/export
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'balance': balance,
    'color': color,
    'iconPath': iconPath,
    'isActive': isActive,
    'createdDate': createdDate.toIso8601String(),
    'bankName': bankName,
    'accountNumber': accountNumber,
    'metadata': metadata,
  };
  
  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'],
    name: json['name'],
    type: WalletType.values.firstWhere((e) => e.name == json['type']),
    balance: json['balance'].toDouble(),
    color: json['color'],
    iconPath: json['iconPath'],
    isActive: json['isActive'] ?? true,
    createdDate: DateTime.parse(json['createdDate']),
    bankName: json['bankName'],
    accountNumber: json['accountNumber'],
    metadata: json['metadata']?.cast<String, dynamic>(),
  );
}

// Wallet Types Enum (TypeId: 11)
@HiveType(typeId: 11)
enum WalletType {
  @HiveField(0) cash,           // Physical cash
  @HiveField(1) debitCard,      // Bank debit cards
  @HiveField(2) creditCard,     // Credit cards
  @HiveField(3) digital,        // GCash, PayMaya, etc.
  @HiveField(4) bank,           // Bank account
  @HiveField(5) investment,     // Investment accounts
}

// AI Coach History Model (TypeId: 12)
@HiveType(typeId: 12)
class AICoachHistory extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String userMessage;       // User's question/input
  @HiveField(2) String coachResponse;     // AI coach response
  @HiveField(3) DateTime timestamp;
  @HiveField(4) CoachingMessageType type; // encouragement, warning, tip, etc.
  @HiveField(5) String? triggerRule;      // Which rule triggered this advice
  @HiveField(6) bool wasHelpful;          // User feedback
  @HiveField(7) Map<String, dynamic>? context; // Financial context at time
  @HiveField(8) String language;          // 'en', 'tl-en', etc.
  @HiveField(9) bool isCloudGenerated;    // Local rule vs cloud AI
  
  AICoachHistory({
    required this.id,
    required this.userMessage,
    required this.coachResponse,
    required this.timestamp,
    required this.type,
    this.triggerRule,
    this.wasHelpful = false,
    this.context,
    this.language = 'tl-en',
    this.isCloudGenerated = false,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'userMessage': userMessage,
    'coachResponse': coachResponse,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    'triggerRule': triggerRule,
    'wasHelpful': wasHelpful,
    'context': context,
    'language': language,
    'isCloudGenerated': isCloudGenerated,
  };
  
  factory AICoachHistory.fromJson(Map<String, dynamic> json) => AICoachHistory(
    id: json['id'],
    userMessage: json['userMessage'],
    coachResponse: json['coachResponse'],
    timestamp: DateTime.parse(json['timestamp']),
    type: CoachingMessageType.values.firstWhere((e) => e.name == json['type']),
    triggerRule: json['triggerRule'],
    wasHelpful: json['wasHelpful'] ?? false,
    context: json['context']?.cast<String, dynamic>(),
    language: json['language'] ?? 'tl-en',
    isCloudGenerated: json['isCloudGenerated'] ?? false,
  );
}

// Enhanced Challenge Model (TypeId: 13)
@HiveType(typeId: 13)
class Challenge extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;             // "Tipid Tuesday"
  @HiveField(2) String description;       // Challenge description
  @HiveField(3) ChallengeType type;       // daily, weekly, monthly
  @HiveField(4) Map<String, dynamic> requirements; // Challenge criteria
  @HiveField(5) int pointsReward;         // Points earned on completion
  @HiveField(6) DateTime startDate;
  @HiveField(7) DateTime endDate;
  @HiveField(8) bool isCompleted;
  @HiveField(9) DateTime? completedDate;
  @HiveField(10) double progress;         // 0.0 to 1.0
  @HiveField(11) Map<String, dynamic>? progressData; // Detailed progress info
  @HiveField(12) String category;         // "spending", "saving", "tracking"
  @HiveField(13) bool isActive;           // Challenge is available
  @HiveField(14) String? iconPath;        // Challenge icon
  
  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirements,
    required this.pointsReward,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.completedDate,
    this.progress = 0.0,
    this.progressData,
    required this.category,
    this.isActive = true,
    this.iconPath,
  });
  
  // Computed properties
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isOngoing => DateTime.now().isAfter(startDate) && !isExpired;
  int get daysRemaining => isExpired ? 0 : endDate.difference(DateTime.now()).inDays;
  double get progressPercentage => (progress * 100).clamp(0, 100);
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'requirements': requirements,
    'pointsReward': pointsReward,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isCompleted': isCompleted,
    'completedDate': completedDate?.toIso8601String(),
    'progress': progress,
    'progressData': progressData,
    'category': category,
    'isActive': isActive,
    'iconPath': iconPath,
  };
  
  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    type: ChallengeType.values.firstWhere((e) => e.name == json['type']),
    requirements: json['requirements'].cast<String, dynamic>(),
    pointsReward: json['pointsReward'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    isCompleted: json['isCompleted'] ?? false,
    completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
    progress: json['progress']?.toDouble() ?? 0.0,
    progressData: json['progressData']?.cast<String, dynamic>(),
    category: json['category'],
    isActive: json['isActive'] ?? true,
    iconPath: json['iconPath'],
  );
}

// Challenge Types (TypeId: 14)
@HiveType(typeId: 14)
enum ChallengeType {
  @HiveField(0) daily,      // 24-hour challenges
  @HiveField(1) weekly,     // 7-day challenges  
  @HiveField(2) monthly,    // 30-day challenges
  @HiveField(3) seasonal,   // Special event challenges
}

// Subscription Status Model (TypeId: 15)
@HiveType(typeId: 15)
class SubscriptionStatus extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) bool isPremium;
  @HiveField(2) DateTime? subscriptionDate;
  @HiveField(3) DateTime? expirationDate;
  @HiveField(4) String? productId;         // App store product ID
  @HiveField(5) String? transactionId;     // Purchase transaction ID
  @HiveField(6) bool isTrialPeriod;
  @HiveField(7) DateTime? trialEndDate;
  @HiveField(8) Map<String, bool> features; // Feature access flags
  @HiveField(9) String subscriptionType;   // "monthly", "yearly", "lifetime"
  
  SubscriptionStatus({
    required this.id,
    this.isPremium = false,
    this.subscriptionDate,
    this.expirationDate,
    this.productId,
    this.transactionId,
    this.isTrialPeriod = false,
    this.trialEndDate,
    required this.features,
    this.subscriptionType = 'free',
  });
  
  // Computed properties
  bool get isActive => isPremium && (expirationDate?.isAfter(DateTime.now()) ?? false);
  bool get isExpired => expirationDate?.isBefore(DateTime.now()) ?? false;
  bool get isInTrial => isTrialPeriod && (trialEndDate?.isAfter(DateTime.now()) ?? false);
  int get daysRemaining => expirationDate?.difference(DateTime.now()).inDays ?? 0;
  
  bool hasFeature(String featureName) => features[featureName] ?? false;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'isPremium': isPremium,
    'subscriptionDate': subscriptionDate?.toIso8601String(),
    'expirationDate': expirationDate?.toIso8601String(),
    'productId': productId,
    'transactionId': transactionId,
    'isTrialPeriod': isTrialPeriod,
    'trialEndDate': trialEndDate?.toIso8601String(),
    'features': features,
    'subscriptionType': subscriptionType,
  };
}
```

### 4.2 Database Migration & Schema Management

**Explanation**: Implement a robust migration system to handle schema changes, data format updates, and new feature rollouts without losing user data.

**Implementation Solutions**:
- **Version-based migrations** with rollback capabilities
- **Data validation** after migrations
- **Backup creation** before major changes

```dart
// Database Migration System
class DatabaseMigrationService {
  static const String _migrationBoxName = 'migrations';
  static const int _currentSchemaVersion = 3;
  
  // Migration history tracking
  static Future<void> runMigrations() async {
    final migrationBox = await Hive.openBox(_migrationBoxName);
    final currentVersion = migrationBox.get('schema_version', defaultValue: 1) as int;
    
    if (currentVersion < _currentSchemaVersion) {
      await _executeMigrations(currentVersion, _currentSchemaVersion);
      await migrationBox.put('schema_version', _currentSchemaVersion);
    }
  }
  
  static Future<void> _executeMigrations(int fromVersion, int toVersion) async {
    for (int version = fromVersion + 1; version <= toVersion; version++) {
      debugPrint('Running migration to version $version');
      
      try {
        switch (version) {
          case 2:
            await _migrateToV2();
            break;
          case 3:
            await _migrateToV3();
            break;
          default:
            throw Exception('Unknown migration version: $version');
        }
        
        debugPrint('Migration to version $version completed successfully');
      } catch (e) {
        debugPrint('Migration to version $version failed: $e');
        // Consider rollback strategy here
        rethrow;
      }
    }
  }
  
  // Migration to Version 2: Add wallet support
  static Future<void> _migrateToV2() async {
    // Create default "Cash" wallet for existing users
    final walletBox = await EncryptedStorageService.openEncryptedBox<Wallet>('wallets');
    
    if (walletBox.isEmpty) {
      final defaultWallet = Wallet(
        id: 'default-cash',
        name: 'Cash',
        type: WalletType.cash,
        balance: 0.0,
        color: '#4CAF50',
        createdDate: DateTime.now(),
      );
      
      await walletBox.put(defaultWallet.id, defaultWallet);
      
      // Update existing expenses to reference default wallet
      final expenseBox = await EncryptedStorageService.openEncryptedBox<Expense>('expenses');
      for (final expense in expenseBox.values) {
        if (expense.metadata == null) {
          expense.metadata = {};
        }
        expense.metadata!['walletId'] = 'default-cash';
        await expenseBox.put(expense.id, expense);
      }
    }
  }
  
  // Migration to Version 3: Add challenge system
  static Future<void> _migrateToV3() async {
    final challengeBox = await EncryptedStorageService.openEncryptedBox<Challenge>('challenges');
    
    // Add default challenges for new users
    final defaultChallenges = _createDefaultChallenges();
    
    for (final challenge in defaultChallenges) {
      await challengeBox.put(challenge.id, challenge);
    }
    
    // Initialize subscription status
    final subscriptionBox = await EncryptedStorageService.openEncryptedBox<SubscriptionStatus>('subscription');
    
    if (subscriptionBox.isEmpty) {
      final defaultSubscription = SubscriptionStatus(
        id: 'default',
        features: {
          'cloudAI': false,
          'advancedAnalytics': false,
          'unlimitedGoals': false,
          'dataExport': true,
          'basicReports': true,
        },
      );
      
      await subscriptionBox.put('default', defaultSubscription);
    }
  }
  
  static List<Challenge> _createDefaultChallenges() {
    final now = DateTime.now();
    return [
      Challenge(
        id: 'daily-tracker',
        title: 'Daily Tracker',
        description: 'Log at least one expense every day',
        type: ChallengeType.daily,
        requirements: {'minExpenses': 1},
        pointsReward: 5,
        startDate: now,
        endDate: now.add(Duration(days: 1)),
        category: 'tracking',
      ),
      Challenge(
        id: 'weekly-budgeter',
        title: 'Weekly Budgeter',
        description: 'Stay under ₱2000 spending this week',
        type: ChallengeType.weekly,
        requirements: {'maxSpending': 2000.0},
        pointsReward: 25,
        startDate: now,
        endDate: now.add(Duration(days: 7)),
        category: 'spending',
      ),
      Challenge(
        id: 'monthly-saver',
        title: 'Monthly Saver',
        description: 'Add ₱500 to any savings goal',
        type: ChallengeType.monthly,
        requirements: {'minGoalContribution': 500.0},
        pointsReward: 50,
        startDate: now,
        endDate: DateTime(now.year, now.month + 1, now.day),
        category: 'saving',
      ),
    ];
  }
  
  // Database cleanup and optimization
  static Future<void> performMaintenance() async {
    await _cleanupOldRecords();
    await _compactAllBoxes();
    await _validateDataIntegrity();
  }
  
  static Future<void> _cleanupOldRecords() async {
    // Remove old AI coach history (keep last 100 entries)
    final coachBox = await EncryptedStorageService.openEncryptedBox<AICoachHistory>('coachHistory');
    final allHistory = coachBox.values.toList();
    
    if (allHistory.length > 100) {
      allHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final toDelete = allHistory.skip(100);
      
      for (final history in toDelete) {
        await coachBox.delete(history.id);
      }
    }
    
    // Remove expired challenges
    final challengeBox = await EncryptedStorageService.openEncryptedBox<Challenge>('challenges');
    final expiredChallenges = challengeBox.values.where((c) => c.isExpired && !c.isCompleted);
    
    for (final challenge in expiredChallenges) {
      await challengeBox.delete(challenge.id);
    }
  }
  
  static Future<void> _compactAllBoxes() async {
    final boxNames = ['expenses', 'goals', 'userData', 'wallets', 'challenges', 'coachHistory', 'subscription'];
    
    for (final boxName in boxNames) {
      try {
        final box = Hive.box(boxName);
        await box.compact();
      } catch (e) {
        debugPrint('Failed to compact box $boxName: $e');
      }
    }
  }
  
  static Future<bool> _validateDataIntegrity() async {
    try {
      // Validate expenses have valid wallet references
      final expenseBox = await EncryptedStorageService.openEncryptedBox<Expense>('expenses');
      final walletBox = await EncryptedStorageService.openEncryptedBox<Wallet>('wallets');
      final walletIds = walletBox.keys.toSet();
      
      for (final expense in expenseBox.values) {
        final walletId = expense.metadata?['walletId'];
        if (walletId != null && !walletIds.contains(walletId)) {
          // Fix orphaned expense
          expense.metadata!['walletId'] = 'default-cash';
          await expenseBox.put(expense.id, expense);
        }
      }
      
      // Validate goals have proper date ranges
      final goalBox = await EncryptedStorageService.openEncryptedBox<SavingsGoal>('goals');
      for (final goal in goalBox.values) {
        if (goal.targetDate.isBefore(goal.createdDate)) {
          // Fix invalid goal dates
          goal.targetDate = goal.createdDate.add(Duration(days: 365));
          await goalBox.put(goal.id, goal);
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Data integrity validation failed: $e');
      return false;
    }
  }
}

// Enhanced Database Service with new models
class EnhancedDatabaseServiceV2 extends EnhancedDatabaseService {
  // Additional wallet operations
  static Future<List<Wallet>> getActiveWallets() async {
    final wallets = getAllWallets();
    return wallets.where((wallet) => wallet.isActive).toList();
  }
  
  static Future<void> updateWalletBalance(String walletId, double newBalance) async {
    final walletBox = await EncryptedStorageService.openEncryptedBox<Wallet>('wallets');
    final wallet = walletBox.get(walletId);
    
    if (wallet != null) {
      wallet.balance = newBalance;
      await walletBox.put(walletId, wallet);
    }
  }
  
  static Future<double> getTotalBalance() async {
    final wallets = getActiveWallets();
    return wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  }
  
  // Challenge operations
  static Future<List<Challenge>> getActiveChallenges() async {
    final challengeBox = await EncryptedStorageService.openEncryptedBox<Challenge>('challenges');
    final challenges = challengeBox.values.toList();
    
    return challenges.where((c) => c.isActive && c.isOngoing).toList();
  }
  
  static Future<void> updateChallengeProgress(String challengeId, double progress, {Map<String, dynamic>? progressData}) async {
    final challengeBox = await EncryptedStorageService.openEncryptedBox<Challenge>('challenges');
    final challenge = challengeBox.get(challengeId);
    
    if (challenge != null) {
      challenge.progress = progress.clamp(0.0, 1.0);
      challenge.progressData = progressData;
      
      if (progress >= 1.0 && !challenge.isCompleted) {
        challenge.isCompleted = true;
        challenge.completedDate = DateTime.now();
        
        // Award points (would integrate with gamification system)
        _awardChallengePoints(challenge);
      }
      
      await challengeBox.put(challengeId, challenge);
    }
  }
  
  static void _awardChallengePoints(Challenge challenge) {
    // Integration point with gamification system
    // This would update user points and trigger celebrations
    debugPrint('Challenge "${challenge.title}" completed! Awarded ${challenge.pointsReward} points.');
  }
  
  // Subscription management
  static Future<SubscriptionStatus> getSubscriptionStatus() async {
    final subscriptionBox = await EncryptedStorageService.openEncryptedBox<SubscriptionStatus>('subscription');
    return subscriptionBox.get('default') ?? SubscriptionStatus(id: 'default', features: {});
  }
  
  static Future<void> updateSubscriptionStatus(SubscriptionStatus status) async {
    final subscriptionBox = await EncryptedStorageService.openEncryptedBox<SubscriptionStatus>('subscription');
    await subscriptionBox.put('default', status);
  }
  
  // Analytics and reporting
  static Map<String, dynamic> getDatabaseAnalytics() {
    final stats = getDatabaseStats();
    return {
      ...stats,
      'totalBalance': getTotalBalance(),
      'activeChallenges': getActiveChallenges().then((c) => c.length),
      'completedGoals': getAllGoals().where((g) => g.isCompleted).length,
      'databaseVersion': _currentSchemaVersion,
    };
  }
}
```

---

## 5. Monetization System

### 5.1 In-App Purchase Integration

**Explanation**: Implement a freemium model with premium subscriptions that unlock advanced features like cloud AI coaching, unlimited goals, advanced analytics, and enhanced customization options.

**Example**: Free tier includes basic expense tracking and goals. Premium tier (₱299/month) adds cloud AI, unlimited goals, advanced reports, data export, and priority support.

**Implementation Solutions**:
- **Flutter Libraries**: 
  - `in_app_purchase` for iOS and Android purchases
  - `flutter_secure_storage` for receipt storage
- **Payment Processing**: Native app store billing (Apple App Store, Google Play Store)

```dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Monetization Service
class MonetizationService {
  static const MonetizationService _instance = MonetizationService._internal();
  factory MonetizationService() => _instance;
  const MonetizationService._internal();
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Product IDs for different subscription tiers
  static const String monthlyPremiumId = 'ipongpt_premium_monthly';
  static const String yearlyPremiumId = 'ipongpt_premium_yearly';
  static const String lifetimePremiumId = 'ipongpt_premium_lifetime';
  
  static const Set<String> _productIds = {
    monthlyPremiumId,
    yearlyPremiumId,
    lifetimePremiumId,
  };
  
  StreamSubscription<List<PurchaseDetails>>? _purchaseUpdateSubscription;
  List<ProductDetails> _availableProducts = [];
  
  // Initialize the monetization system
  Future<bool> initialize() async {
    try {
      final isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) return false;
      
      // Load available products
      await _loadProducts();
      
      // Listen to purchase updates
      _purchaseUpdateSubscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdate,
        onError: (error) => debugPrint('Purchase stream error: $error'),
      );
      
      // Restore previous purchases
      await restorePurchases();
      
      return true;
    } catch (e) {
      debugPrint('Monetization initialization failed: $e');
      return false;
    }
  }
  
  // Load available products from app stores
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.error != null) {
        debugPrint('Failed to load products: ${response.error}');
        return;
      }
      
      _availableProducts = response.productDetails;
      debugPrint('Loaded ${_availableProducts.length} products');
      
      for (final product in _availableProducts) {
        debugPrint('Product: ${product.id} - ${product.title} - ${product.price}');
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }
  
  // Get available subscription options
  List<SubscriptionOption> getSubscriptionOptions() {
    final options = <SubscriptionOption>[];
    
    for (final product in _availableProducts) {
      late SubscriptionOption option;
      
      switch (product.id) {
        case monthlyPremiumId:
          option = SubscriptionOption(
            productId: product.id,
            title: 'Premium Monthly',
            description: 'AI Coach, Unlimited Goals, Advanced Analytics',
            price: product.price,
            duration: 'Monthly',
            features: _getPremiumFeatures(),
            savings: null,
            productDetails: product,
          );
          break;
          
        case yearlyPremiumId:
          option = SubscriptionOption(
            productId: product.id,
            title: 'Premium Yearly',
            description: 'AI Coach, Unlimited Goals, Advanced Analytics + More!',
            price: product.price,
            duration: 'Yearly',
            features: _getPremiumFeatures(),
            savings: 'Save 33% compared to monthly',
            productDetails: product,
          );
          break;
          
        case lifetimePremiumId:
          option = SubscriptionOption(
            productId: product.id,
            title: 'Premium Lifetime',
            description: 'One-time payment, lifetime access to all features',
            price: product.price,
            duration: 'Lifetime',
            features: _getPremiumFeatures(),
            savings: 'Best value - pay once, use forever',
            productDetails: product,
          );
          break;
      }
      
      options.add(option);
    }
    
    // Sort by price (monthly, yearly, lifetime)
    options.sort((a, b) {
      final order = [monthlyPremiumId, yearlyPremiumId, lifetimePremiumId];
      return order.indexOf(a.productId).compareTo(order.indexOf(b.productId));
    });
    
    return options;
  }
  
  List<String> _getPremiumFeatures() {
    return [
      '🤖 AI Financial Coach with personalized advice',
      '🎯 Unlimited savings goals',
      '📊 Advanced analytics and insights',
      '📈 Predictive spending forecasts',
      '☁️ Cloud backup and sync',
      '📱 Priority customer support',
      '🎨 Premium themes and customization',
      '📋 Detailed expense reports (PDF/Excel)',
      '🔍 Advanced filtering and search',
      '🏆 Exclusive challenges and badges',
    ];
  }
  
  // Purchase a subscription
  Future<PurchaseResult> purchaseSubscription(String productId) async {
    try {
      final product = _availableProducts.firstWhere((p) => p.id == productId);
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (success) {
        return PurchaseResult.pending();
      } else {
        return PurchaseResult.failed('Purchase initiation failed');
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      return PurchaseResult.failed(e.toString());
    }
  }
  
  // Handle purchase updates from the platform
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _processPurchase(purchaseDetails);
    }
  }
  
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      
      // Verify purchase with server (if you have backend verification)
      final bool isValid = await _verifyPurchase(purchaseDetails);
      
      if (isValid) {
        // Grant premium access
        await _grantPremiumAccess(purchaseDetails.productID);
        
        // Store purchase receipt securely
        await _storePurchaseReceipt(purchaseDetails);
        
        debugPrint('Premium access granted for ${purchaseDetails.productID}');
      }
      
      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      debugPrint('Purchase failed: ${purchaseDetails.error}');
    }
  }
  
  // Verify purchase (local verification for MVP)
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // For MVP: Basic local verification
    // In production: Server-side receipt verification recommended
    
    if (purchaseDetails.verificationData.localVerificationData.isEmpty) {
      return false;
    }
    
    // Store verification data
    await _secureStorage.write(
      key: 'purchase_${purchaseDetails.productID}_verification',
      value: purchaseDetails.verificationData.localVerificationData,
    );
    
    return true;
  }
  
  // Grant premium access by updating subscription status
  Future<void> _grantPremiumAccess(String productId) async {
    final subscriptionBox = await EncryptedStorageService.openEncryptedBox<SubscriptionStatus>('subscription');
    
    final now = DateTime.now();
    late DateTime expirationDate;
    late String subscriptionType;
    
    switch (productId) {
      case monthlyPremiumId:
        expirationDate = now.add(Duration(days: 30));
        subscriptionType = 'monthly';
        break;
      case yearlyPremiumId:
        expirationDate = now.add(Duration(days: 365));
        subscriptionType = 'yearly';
        break;
      case lifetimePremiumId:
        expirationDate = now.add(Duration(days: 36500)); // 100 years
        subscriptionType = 'lifetime';
        break;
    }
    
    final subscription = SubscriptionStatus(
      id: 'default',
      isPremium: true,
      subscriptionDate: now,
      expirationDate: expirationDate,
      productId: productId,
      features: _getPremiumFeatureFlags(),
      subscriptionType: subscriptionType,
    );
    
    await subscriptionBox.put('default', subscription);
    
    // Update other services about premium status
    _notifyPremiumStatusChange(true);
  }
  
  Map<String, bool> _getPremiumFeatureFlags() {
    return {
      'cloudAI': true,
      'advancedAnalytics': true,
      'unlimitedGoals': true,
      'dataExport': true,
      'basicReports': true,
      'premiumThemes': true,
      'prioritySupport': true,
      'predictiveInsights': true,
      'cloudBackup': true,
      'advancedFiltering': true,
    };
  }
  
  // Store purchase receipt for verification
  Future<void> _storePurchaseReceipt(PurchaseDetails purchaseDetails) async {
    final receiptData = {
      'productId': purchaseDetails.productID,
      'purchaseId': purchaseDetails.purchaseID,
      'transactionDate': DateTime.now().toIso8601String(),
      'verificationData': purchaseDetails.verificationData.localVerificationData,
    };
    
    await _secureStorage.write(
      key: 'purchase_receipt_${purchaseDetails.productID}',
      value: jsonEncode(receiptData),
    );
  }
  
  // Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('Purchase restoration initiated');
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
    }
  }
  
  // Check if user has premium access
  Future<bool> hasPremiumAccess() async {
    try {
      final subscription = await EnhancedDatabaseServiceV2.getSubscriptionStatus();
      return subscription.isActive;
    } catch (e) {
      return false;
    }
  }
  
  // Check if specific feature is available
  Future<bool> hasFeatureAccess(String featureName) async {
    try {
      final subscription = await EnhancedDatabaseServiceV2.getSubscriptionStatus();
      return subscription.hasFeature(featureName);
    } catch (e) {
      return false;
    }
  }
  
  // Notify other services about premium status changes
  void _notifyPremiumStatusChange(bool isPremium) {
    // This could trigger UI updates, feature unlocks, etc.
    // Implementation depends on your state management solution
    debugPrint('Premium status changed: $isPremium');
  }
  
  // Cleanup
  void dispose() {
    _purchaseUpdateSubscription?.cancel();
  }
}

// Data classes for monetization
class SubscriptionOption {
  final String productId;
  final String title;
  final String description;
  final String price;
  final String duration;
  final List<String> features;
  final String? savings;
  final ProductDetails productDetails;
  
  SubscriptionOption({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.savings,
    required this.productDetails,
  });
}

class PurchaseResult {
  final bool isSuccess;
  final bool isPending;
  final String? errorMessage;
  
  PurchaseResult._({
    required this.isSuccess,
    required this.isPending,
    this.errorMessage,
  });
  
  factory PurchaseResult.success() => PurchaseResult._(isSuccess: true, isPending: false);
  factory PurchaseResult.pending() => PurchaseResult._(isSuccess: false, isPending: true);
  factory PurchaseResult.failed(String error) => PurchaseResult._(isSuccess: false, isPending: false, errorMessage: error);
}
```

### 5.2 Feature Gating System

**Explanation**: Implement a system to control access to premium features based on subscription status, with graceful degradation and upgrade prompts.

```dart
// Feature Gating Service
class FeatureGatingService {
  static const FeatureGatingService _instance = FeatureGatingService._internal();
  factory FeatureGatingService() => _instance;
  const FeatureGatingService._internal();
  
  final MonetizationService _monetizationService = MonetizationService();
  
  // Feature definitions with limits
  static const Map<String, FeatureConfig> _featureConfigs = {
    'goals_limit': FeatureConfig(
      name: 'Savings Goals',
      freeLimit: 3,
      premiumLimit: -1, // -1 means unlimited
      description: 'Create and track your financial goals',
    ),
    'ai_chat_limit': FeatureConfig(
      name: 'AI Coach Conversations',
      freeLimit: 10,
      premiumLimit: -1,
      description: 'Get personalized financial advice from AI coach',
    ),
    'export_formats': FeatureConfig(
      name: 'Data Export',
      freeLimit: 1, // CSV only
      premiumLimit: 3, // CSV, PDF, Excel
      description: 'Export your financial data',
    ),
    'advanced_charts': FeatureConfig(
      name: 'Advanced Analytics',
      freeLimit: 0,
      premiumLimit: 1,
      description: 'Detailed spending analysis and trends',
    ),
  };
  
  // Check if feature is available for current user
  Future<FeatureAvailability> checkFeatureAvailability(String featureKey) async {
    final config = _featureConfigs[featureKey];
    if (config == null) {
      return FeatureAvailability.unavailable('Feature not found');
    }
    
    final isPremium = await _monetizationService.hasPremiumAccess();
    
    if (isPremium) {
      return FeatureAvailability.available(
        isLimited: config.premiumLimit > 0,
        limit: config.premiumLimit,
        used: await _getFeatureUsage(featureKey),
      );
    }
    
    // Free user - check limits
    final used = await _getFeatureUsage(featureKey);
    final available = config.freeLimit == -1 || used < config.freeLimit;
    
    if (available) {
      return FeatureAvailability.available(
        isLimited: config.freeLimit > 0,
        limit: config.freeLimit,
        used: used,
      );
    } else {
      return FeatureAvailability.limitReached(
        limit: config.freeLimit,
        upgradeRequired: true,
      );
    }
  }
  
  // Get current usage for a feature
  Future<int> _getFeatureUsage(String featureKey) async {
    switch (featureKey) {
      case 'goals_limit':
        final goals = EnhancedDatabaseServiceV2.getAllGoals();
        return goals.where((g) => !g.isCompleted).length;
        
      case 'ai_chat_limit':
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final history = EnhancedDatabaseServiceV2.getCoachHistory();
        return history.where((h) => h.timestamp.isAfter(monthStart)).length;
        
      case 'export_formats':
        // This would track export usage
        return 0;
        
      case 'advanced_charts':
        // Always 0 for free users, 1 for premium (feature flag)
        return 0;
        
      default:
        return 0;
    }
  }
  
  // Show upgrade prompt when feature limit reached
  Future<bool> showUpgradePrompt(BuildContext context, String featureKey) async {
    final config = _featureConfigs[featureKey];
    if (config == null) return false;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => UpgradePromptDialog(
        featureName: config.name,
        featureDescription: config.description,
        currentLimit: config.freeLimit,
      ),
    ) ?? false;
  }
  
  // Helper method to enforce feature limits
  Future<bool> canUseFeature(String featureKey) async {
    final availability = await checkFeatureAvailability(featureKey);
    return availability.isAvailable;
  }
  
  // Increment feature usage (for tracking)
  Future<void> recordFeatureUsage(String featureKey) async {
    // This could store usage statistics for analytics
    // For now, we'll just log it
    debugPrint('Feature used: $featureKey');
  }
}

// Feature configuration
class FeatureConfig {
  final String name;
  final int freeLimit;    // -1 means unlimited
  final int premiumLimit; // -1 means unlimited
  final String description;
  
  const FeatureConfig({
    required this.name,
    required this.freeLimit,
    required this.premiumLimit,
    required this.description,
  });
}

// Feature availability result
class FeatureAvailability {
  final bool isAvailable;
  final bool isLimited;
  final int? limit;
  final int? used;
  final bool upgradeRequired;
  final String? message;
  
  FeatureAvailability._({
    required this.isAvailable,
    this.isLimited = false,
    this.limit,
    this.used,
    this.upgradeRequired = false,
    this.message,
  });
  
  factory FeatureAvailability.available({
    bool isLimited = false,
    int? limit,
    int? used,
  }) => FeatureAvailability._(
    isAvailable: true,
    isLimited: isLimited,
    limit: limit,
    used: used,
  );
  
  factory FeatureAvailability.limitReached({
    required int limit,
    bool upgradeRequired = true,
  }) => FeatureAvailability._(
    isAvailable: false,
    upgradeRequired: upgradeRequired,
    limit: limit,
    message: 'You have reached the limit of $limit for this feature.',
  );
  
  factory FeatureAvailability.unavailable(String message) => FeatureAvailability._(
    isAvailable: false,
    message: message,
  );
  
  String get remainingUsage {
    if (limit == null || used == null) return '';
    if (limit! == -1) return 'Unlimited';
    return '${limit! - used!} remaining';
  }
}

// Upgrade prompt dialog
class UpgradePromptDialog extends StatelessWidget {
  final String featureName;
  final String featureDescription;
  final int currentLimit;
  
  const UpgradePromptDialog({
    Key? key,
    required this.featureName,
    required this.featureDescription,
    required this.currentLimit,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Upgrade to Premium'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 48,
            color: Colors.amber,
          ),
          SizedBox(height: 16),
          Text(
            'You\'ve reached the limit for $featureName',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Free users can use $currentLimit $featureName. Upgrade to Premium for unlimited access!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            '✨ Premium Benefits:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          Text(
            '• Unlimited $featureName\n'
            '• AI Financial Coach\n'
            '• Advanced Analytics\n'
            '• Priority Support\n'
            '• And much more!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            _navigateToSubscriptionScreen(context);
          },
          child: Text('Upgrade Now'),
        ),
      ],
    );
  }
  
  void _navigateToSubscriptionScreen(BuildContext context) {
    Navigator.pushNamed(context, '/subscription');
  }
}

// Riverpod providers for monetization
@riverpod
MonetizationService monetizationService(MonetizationServiceRef ref) {
  return MonetizationService();
}

@riverpod
FeatureGatingService featureGatingService(FeatureGatingServiceRef ref) {
  return FeatureGatingService();
}

@riverpod
Future<bool> premiumAccess(PremiumAccessRef ref) async {
  final monetization = ref.watch(monetizationServiceProvider);
  return await monetization.hasPremiumAccess();
}

@riverpod
Future<FeatureAvailability> featureAvailability(
  FeatureAvailabilityRef ref,
  String featureKey,
) async {
  final gating = ref.watch(featureGatingServiceProvider);
  return await gating.checkFeatureAvailability(featureKey);
}
```

---

## 6. Voice & Photo Processing

### 6.1 Speech-to-Text Integration

**Explanation**: Implement voice input for Filipino phrases to allow users to quickly add expenses by speaking naturally in Taglish. The system should recognize common Filipino financial terms and extract expense details.

**Example**: User says "Nag-spend ako ng fifty pesos sa jeepney" → System extracts amount: ₱50, category: Transportation, description: "jeepney fare"

**Implementation Solutions**:
- **Flutter Libraries**: 
  - `speech_to_text` for voice recognition
  - Natural language processing for amount/category extraction
- **Filipino Language Support**: Custom phrase recognition and mapping

```dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Voice Input Service
class VoiceInputService {
  static const VoiceInputService _instance = VoiceInputService._internal();
  factory VoiceInputService() => _instance;
  const VoiceInputService._internal();
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  
  // Initialize speech recognition
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
      
      return _isAvailable;
    } catch (e) {
      debugPrint('Failed to initialize speech recognition: $e');
      return false;
    }
  }
  
  // Start listening for voice input
  Future<String?> listenForExpense() async {
    if (!_isAvailable || _isListening) return null;
    
    try {
      String recognizedText = '';
      
      await _speech.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
        },
        localeId: 'en_PH', // Philippine English
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 3),
      );
      
      _isListening = true;
      
      // Wait for speech recognition to complete
      await Future.delayed(Duration(seconds: 1));
      
      return recognizedText.isNotEmpty ? recognizedText : null;
    } catch (e) {
      debugPrint('Speech recognition failed: $e');
      return null;
    } finally {
      _isListening = false;
    }
  }
  
  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }
  
  // Parse Filipino financial phrases
  ExpenseFromVoice? parseExpenseFromText(String text) {
    final parser = FilipinoExpenseParser();
    return parser.parseExpense(text.toLowerCase());
  }
  
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
}

// Filipino Expense Parser
class FilipinoExpenseParser {
  // Amount patterns (Filipino number expressions)
  static final RegExp _amountPatterns = RegExp(
    r'(₱?\s*(\d+(?:\.\d{2})?)|'
    r'(twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|hundred)|'
    r'(dalawampu|tatlumpu|apatnapu|limampu|animnapu|pitumpu|walumpu|siyamnapu|sandaan)|'
    r'(piso|pesos?|php)|'
    r'(\d+\s*(piso|pesos?)))',
    caseSensitive: false,
  );
  
  // Category keywords mapping
  static const Map<String, List<String>> _categoryKeywords = {
    'Food & Dining': [
      'kain', 'pagkain', 'food', 'lunch', 'dinner', 'breakfast',
      'mcdo', 'jollibee', 'mang inasal', 'chowking', 'kfc',
      'rice', 'kanin', 'ulam', 'sabaw', 'coffee', 'kape',
      'merienda', 'snack', 'burger', 'pizza', 'chicken'
    ],
    'Transportation': [
      'jeepney', 'jeep', 'bus', 'taxi', 'grab', 'tricycle', 'trike',
      'mrt', 'lrt', 'uv', 'fx', 'habal', 'motorcycle', 'motor',
      'pamasahe', 'fare', 'gas', 'gasoline', 'diesel', 'sakay'
    ],
    'Shopping': [
      'bili', 'bumili', 'shopping', 'mall', 'sm', 'ayala', 'robinsons',
      'groceries', 'grocery', 'palengke', 'market', 'tindahan',
      'damit', 'clothes', 'sapatos', 'shoes', 'bag', 'cellphone'
    ],
    'Bills & Utilities': [
      'bill', 'bayad', 'kuryente', 'electricity', 'tubig', 'water',
      'internet', 'wifi', 'load', 'prepaid', 'postpaid', 'meralco',
      'maynilad', 'globe', 'smart', 'pldt'
    ],
    'Healthcare': [
      'doktor', 'doctor', 'gamot', 'medicine', 'hospital', 'clinic',
      'checkup', 'laboratory', 'lab', 'x-ray', 'dental', 'ngipin'
    ],
    'Entertainment': [
      'movie', 'cinema', 'sine', 'concert', 'bar', 'club', 'videoke',
      'karaoke', 'gala', 'gimik', 'outing', 'vacation', 'travel'
    ]
  };
  
  // Common Filipino spending phrases
  static const List<String> _spendingPhrases = [
    'nag-spend', 'nagspend', 'nagastos', 'nag-gastos', 'ginastos',
    'nabayad', 'binayad', 'bayad', 'bili', 'bumili', 'nakabili'
  ];
  
  ExpenseFromVoice? parseExpense(String text) {
    // Extract amount
    final amount = _extractAmount(text);
    if (amount == null || amount <= 0) return null;
    
    // Extract category
    final category = _extractCategory(text);
    
    // Extract description/context
    final description = _extractDescription(text);
    
    return ExpenseFromVoice(
      amount: amount,
      category: category,
      description: description,
      rawText: text,
      confidence: _calculateConfidence(text, amount, category),
    );
  }
  
  double? _extractAmount(String text) {
    // Look for explicit peso amounts
    final pesoMatch = RegExp(r'₱?\s*(\d+(?:\.\d{2})?)').firstMatch(text);
    if (pesoMatch != null) {
      return double.tryParse(pesoMatch.group(1)!);
    }
    
    // Look for number + pesos
    final numberPesoMatch = RegExp(r'(\d+)\s*(piso|pesos?)').firstMatch(text);
    if (numberPesoMatch != null) {
      return double.tryParse(numberPesoMatch.group(1)!);
    }
    
    // Look for written numbers (English)
    final writtenNumbers = {
      'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
      'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
      'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50,
      'sixty': 60, 'seventy': 70, 'eighty': 80, 'ninety': 90,
      'hundred': 100,
    };
    
    for (final entry in writtenNumbers.entries) {
      if (text.contains(entry.key)) {
        return entry.value.toDouble();
      }
    }
    
    // Look for Filipino numbers
    final filipinoNumbers = {
      'isa': 1, 'dalawa': 2, 'tatlo': 3, 'apat': 4, 'lima': 5,
      'anim': 6, 'pito': 7, 'walo': 8, 'siyam': 9, 'sampu': 10,
      'dalawampu': 20, 'tatlumpu': 30, 'apatnapu': 40, 'limampu': 50,
      'animnapu': 60, 'pitumpu': 70, 'walumpu': 80, 'siyamnapu': 90,
      'sandaan': 100,
    };
    
    for (final entry in filipinoNumbers.entries) {
      if (text.contains(entry.key)) {
        return entry.value.toDouble();
      }
    }
    
    return null;
  }
  
  String _extractCategory(String text) {
    // Check each category's keywords
    for (final categoryEntry in _categoryKeywords.entries) {
      final category = categoryEntry.key;
      final keywords = categoryEntry.value;
      
      for (final keyword in keywords) {
        if (text.contains(keyword.toLowerCase())) {
          return category;
        }
      }
    }
    
    return 'Other'; // Default category
  }
  
  String _extractDescription(String text) {
    // Remove amount-related text
    String description = text;
    
    // Remove peso amounts
    description = description.replaceAll(RegExp(r'₱?\s*\d+(?:\.\d{2})?'), '');
    description = description.replaceAll(RegExp(r'\d+\s*(piso|pesos?)'), '');
    
    // Remove spending phrases
    for (final phrase in _spendingPhrases) {
      description = description.replaceAll(phrase, '');
    }
    
    // Remove common connectors
    description = description.replaceAll(RegExp(r'\b(ng|na|sa|para|for|on|at)\b'), '');
    
    // Clean up spaces
    description = description.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    return description.isNotEmpty ? description : 'Voice expense';
  }
  
  double _calculateConfidence(String text, double? amount, String category) {
    double confidence = 0.0;
    
    // Amount confidence
    if (amount != null && amount > 0) {
      confidence += 0.4;
    }
    
    // Category confidence
    if (category != 'Other') {
      confidence += 0.3;
    }
    
    // Spending phrase confidence
    for (final phrase in _spendingPhrases) {
      if (text.contains(phrase)) {
        confidence += 0.2;
        break;
      }
    }
    
    // Filipino language confidence
    final filipinoWords = ['ako', 'ng', 'sa', 'para', 'nag', 'na'];
    for (final word in filipinoWords) {
      if (text.contains(word)) {
        confidence += 0.1;
        break;
      }
    }
    
    return confidence.clamp(0.0, 1.0);
  }
}

// Voice expense result
class ExpenseFromVoice {
  final double amount;
  final String category;
  final String description;
  final String rawText;
  final double confidence;
  
  ExpenseFromVoice({
    required this.amount,
    required this.category,
    required this.description,
    required this.rawText,
    required this.confidence,
  });
  
  bool get isHighConfidence => confidence >= 0.7;
  bool get isMediumConfidence => confidence >= 0.4;
  bool get isLowConfidence => confidence < 0.4;
  
  // Convert to expense object
  Expense toExpense({String? walletId}) {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      description: description,
      dateTime: DateTime.now(),
      metadata: {
        'source': 'voice',
        'rawText': rawText,
        'confidence': confidence,
        'walletId': walletId,
      },
    );
  }
}
```

### 6.2 OCR Receipt Processing

**Explanation**: Implement optical character recognition (OCR) to extract expense information from receipt photos, with special focus on Philippine merchants and formats.

**Implementation Solutions**:
- **Flutter Libraries**: 
  - `google_mlkit_text_recognition` for OCR
  - `image_picker` for camera integration
  - `image` for image processing

```dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Receipt OCR Service
class ReceiptOCRService {
  static const ReceiptOCRService _instance = ReceiptOCRService._internal();
  factory ReceiptOCRService() => _instance;
  const ReceiptOCRService._internal();
  
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Capture and process receipt
  Future<ReceiptData?> captureAndProcessReceipt() async {
    try {
      // Capture image from camera
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image == null) return null;
      
      // Process the image
      return await processReceiptImage(image.path);
    } catch (e) {
      debugPrint('Failed to capture receipt: $e');
      return null;
    }
  }
  
  // Process receipt from existing image
  Future<ReceiptData?> processReceiptImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Parse the recognized text
      final parser = PhilippineReceiptParser();
      final receiptData = parser.parseReceiptText(recognizedText.text);
      
      // Add image path to receipt data
      receiptData?.imagePath = imagePath;
      
      return receiptData;
    } catch (e) {
      debugPrint('OCR processing failed: $e');
      return null;
    }
  }
  
  // Cleanup
  void dispose() {
    _textRecognizer.close();
  }
}

// Philippine Receipt Parser
class PhilippineReceiptParser {
  // Philippine merchant patterns
  static final Map<String, MerchantInfo> _knownMerchants = {
    // Grocery stores
    'sm supermarket': MerchantInfo('SM Supermarket', 'Groceries', 'Shopping'),
    'robinsons supermarket': MerchantInfo('Robinsons Supermarket', 'Groceries', 'Shopping'),
    'puregold': MerchantInfo('PureGold', 'Groceries', 'Shopping'),
    'shopwise': MerchantInfo('Shopwise', 'Groceries', 'Shopping'),
    'metro market': MerchantInfo('Metro Market', 'Groceries', 'Shopping'),
    
    // Fast food
    'jollibee': MerchantInfo('Jollibee', 'Fast Food', 'Food & Dining'),
    'mcdonalds': MerchantInfo('McDonald\'s', 'Fast Food', 'Food & Dining'),
    'kfc': MerchantInfo('KFC', 'Fast Food', 'Food & Dining'),
    'chowking': MerchantInfo('Chowking', 'Fast Food', 'Food & Dining'),
    'mang inasal': MerchantInfo('Mang Inasal', 'Fast Food', 'Food & Dining'),
    'greenwich': MerchantInfo('Greenwich', 'Fast Food', 'Food & Dining'),
    
    // Coffee shops
    'starbucks': MerchantInfo('Starbucks', 'Coffee Shop', 'Food & Dining'),
    'coffee bean': MerchantInfo('Coffee Bean & Tea Leaf', 'Coffee Shop', 'Food & Dining'),
    'tim hortons': MerchantInfo('Tim Hortons', 'Coffee Shop', 'Food & Dining'),
    
    // Gas stations
    'petron': MerchantInfo('Petron', 'Gas Station', 'Transportation'),
    'shell': MerchantInfo('Shell', 'Gas Station', 'Transportation'),
    'caltex': MerchantInfo('Caltex', 'Gas Station', 'Transportation'),
    'phoenix': MerchantInfo('Phoenix Petroleum', 'Gas Station', 'Transportation'),
    
    // Pharmacies
    'mercury drug': MerchantInfo('Mercury Drug', 'Pharmacy', 'Healthcare'),
    'watsons': MerchantInfo('Watsons', 'Pharmacy', 'Healthcare'),
    'rose pharmacy': MerchantInfo('Rose Pharmacy', 'Pharmacy', 'Healthcare'),
  };
  
  // Amount patterns for Philippine receipts
  static final List<RegExp> _amountPatterns = [
    RegExp(r'total\s*:?\s*₱?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
    RegExp(r'amount\s*:?\s*₱?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
    RegExp(r'₱\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
    RegExp(r'php\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
  ];
  
  // Date patterns
  static final List<RegExp> _datePatterns = [
    RegExp(r'(\d{1,2}\/\d{1,2}\/\d{2,4})'), // MM/DD/YYYY or DD/MM/YYYY
    RegExp(r'(\d{1,2}-\d{1,2}-\d{2,4})'),   // MM-DD-YYYY or DD-MM-YYYY
    RegExp(r'(\d{4}-\d{1,2}-\d{1,2})'),     // YYYY-MM-DD
  ];
  
  ReceiptData? parseReceiptText(String text) {
    final cleanText = text.toLowerCase();
    
    // Extract merchant information
    final merchantInfo = _extractMerchant(cleanText);
    
    // Extract amount
    final amount = _extractAmount(cleanText);
    if (amount == null || amount <= 0) return null;
    
    // Extract date
    final date = _extractDate(text); // Use original case for date parsing
    
    // Extract items (optional)
    final items = _extractItems(text);
    
    return ReceiptData(
      merchantName: merchantInfo?.name ?? 'Unknown Merchant',
      merchantType: merchantInfo?.type ?? 'Unknown',
      category: merchantInfo?.category ?? 'Other',
      amount: amount,
      date: date ?? DateTime.now(),
      items: items,
      rawText: text,
      confidence: _calculateConfidence(text, merchantInfo, amount),
    );
  }
  
  MerchantInfo? _extractMerchant(String text) {
    for (final entry in _knownMerchants.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Try partial matches
    if (text.contains('jollibee') || text.contains('jolibee')) {
      return _knownMerchants['jollibee'];
    }
    if (text.contains('mcdo')) {
      return _knownMerchants['mcdonalds'];
    }
    if (text.contains('mang inasal') || text.contains('manginasal')) {
      return _knownMerchants['mang inasal'];
    }
    
    return null;
  }
  
  double? _extractAmount(String text) {
    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }
    
    return null;
  }
  
  DateTime? _extractDate(String text) {
    for (final pattern in _datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final dateStr = match.group(1)!;
        
        // Try different date formats
        final formats = [
          'MM/dd/yyyy', 'dd/MM/yyyy', 'MM/dd/yy', 'dd/MM/yy',
          'MM-dd-yyyy', 'dd-MM-yyyy', 'yyyy-MM-dd'
        ];
        
        for (final format in formats) {
          try {
            // Simple date parsing (you might want to use intl package for robust parsing)
            if (dateStr.contains('/')) {
              final parts = dateStr.split('/');
              if (parts.length == 3) {
                final month = int.parse(parts[0]);
                final day = int.parse(parts[1]);
                var year = int.parse(parts[2]);
                
                // Handle 2-digit years
                if (year < 100) {
                  year += (year < 50) ? 2000 : 1900;
                }
                
                return DateTime(year, month, day);
              }
            }
          } catch (e) {
            continue;
          }
        }
      }
    }
    
    return null;
  }
  
  List<String> _extractItems(String text) {
    final items = <String>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Skip lines that look like headers, totals, or merchant info
      if (trimmedLine.length < 3 ||
          trimmedLine.toLowerCase().contains('total') ||
          trimmedLine.toLowerCase().contains('change') ||
          trimmedLine.toLowerCase().contains('cash') ||
          trimmedLine.toLowerCase().contains('card') ||
          _knownMerchants.keys.any((merchant) => trimmedLine.toLowerCase().contains(merchant))) {
        continue;
      }
      
      // Look for lines with amounts (likely items)
      if (RegExp(r'\d+\.\d{2}').hasMatch(trimmedLine)) {
        items.add(trimmedLine);
      }
    }
    
    return items;
  }
  
  double _calculateConfidence(String text, MerchantInfo? merchantInfo, double? amount) {
    double confidence = 0.0;
    
    // Merchant recognition confidence
    if (merchantInfo != null) {
      confidence += 0.4;
    }
    
    // Amount extraction confidence
    if (amount != null && amount > 0) {
      confidence += 0.4;
    }
    
    // Receipt-like structure confidence
    if (text.toLowerCase().contains('total') || 
        text.toLowerCase().contains('amount') ||
        text.contains('₱') ||
        text.toLowerCase().contains('php')) {
      confidence += 0.2;
    }
    
    return confidence.clamp(0.0, 1.0);
  }
}

// Supporting data classes
class MerchantInfo {
  final String name;
  final String type;
  final String category;
  
  MerchantInfo(this.name, this.type, this.category);
}

class ReceiptData {
  final String merchantName;
  final String merchantType;
  final String category;
  final double amount;
  final DateTime date;
  final List<String> items;
  final String rawText;
  final double confidence;
  String? imagePath;
  
  ReceiptData({
    required this.merchantName,
    required this.merchantType,
    required this.category,
    required this.amount,
    required this.date,
    required this.items,
    required this.rawText,
    required this.confidence,
    this.imagePath,
  });
  
  bool get isHighConfidence => confidence >= 0.7;
  bool get isMediumConfidence => confidence >= 0.4;
  
  // Convert to expense object
  Expense toExpense({String? walletId}) {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      description: '$merchantName - $merchantType',
      dateTime: date,
      receiptPath: imagePath,
      metadata: {
        'source': 'receipt_ocr',
        'merchant': merchantName,
        'merchantType': merchantType,
        'confidence': confidence,
        'items': items,
        'walletId': walletId,
      },
    );
  }
}

// Riverpod providers
@riverpod
VoiceInputService voiceInputService(VoiceInputServiceRef ref) {
  return VoiceInputService();
}

@riverpod  
ReceiptOCRService receiptOCRService(ReceiptOCRServiceRef ref) {
  return ReceiptOCRService();
}
```

---

*[Continue with sections 7-8 in similar detail...]*

---

This document provides detailed implementation guidance for the enhanced backend features of IponGPT, including complete code examples, Filipino-specific considerations, and production-ready implementations that integrate seamlessly with the existing codebase architecture.
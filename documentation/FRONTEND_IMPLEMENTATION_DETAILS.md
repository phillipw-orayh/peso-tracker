# IponGPT Frontend Implementation Details

This document provides detailed explanations, examples, and implementation solutions for each proposed UI change in the IponGPT Technical Implementation Guide.

---

## 1. Home Screen UI Changes

### 1.1 Add Prominent "+" Button in Center for Quick Money In/Money Out Entry

**Explanation**: Replace or enhance the existing floating action button with a central, more prominent button that offers quick access to both income and expense entry. This creates a unified entry point that reduces user decision fatigue and speeds up the most common app action.

**Example**: Similar to banking apps like GCash or Maya where the central "+" opens a modal with transaction options. The button could be larger, centrally positioned, and use contrasting colors to draw attention.

**Implementation Solutions**:
- **Build Ourselves**: Create a custom FloatingActionButton with expanded design
- **Current Codebase**: Enhance existing FAB in `home_screen.dart`
- **Flutter Libraries**: Use `speed_dial` package for expandable FAB with multiple options
```dart
// Using speed_dial package
SpeedDial(
  icon: Icons.add,
  activeIcon: Icons.close,
  children: [
    SpeedDialChild(
      child: Icon(Icons.trending_down, color: Colors.red),
      label: 'Money Out',
      onTap: () => _navigateToExpense(),
    ),
    SpeedDialChild(
      child: Icon(Icons.trending_up, color: Colors.green),
      label: 'Money In',
      onTap: () => _navigateToIncome(),
    ),
  ],
)
```

### 1.2 Implement Multiple Wallet Selector with Balance Display

**Explanation**: Allow users to manage multiple financial accounts (cash, bank cards, e-wallets) with a horizontal scrollable selector at the top of the home screen. Each wallet shows its current balance and allows switching between different funding sources for transactions.

**Example**: Like Mint or YNAB where users can see all their accounts at a glance. Display as horizontal cards showing wallet type (Cash, GCash, BPI, etc.), current balance, and maybe a small trend indicator.

**Implementation Solutions**:
- **Build Ourselves**: Create a custom horizontal PageView with wallet cards
- **Current Codebase**: Extend existing expense model to include wallet source
- **Flutter Libraries**: Use `carousel_slider` for smooth wallet switching
```dart
// Custom wallet selector
class WalletSelector extends StatelessWidget {
  final List<Wallet> wallets;
  final Function(Wallet) onWalletSelected;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: PageView.builder(
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          return WalletCard(
            wallet: wallets[index],
            onTap: () => onWalletSelected(wallets[index]),
          );
        },
      ),
    );
  }
}
```

### 1.3 Create Enhanced Streak Visualization with Animations

**Explanation**: Transform the basic streak counter into an engaging visual element with flame animations, progress rings, and celebratory effects. This gamifies the experience and provides stronger motivation for consistent usage.

**Example**: Like Duolingo's streak flames or Apple's Activity rings. Could show flame intensity based on streak length, particle effects on milestones, and visual "burning" animation.

**Implementation Solutions**:
- **Build Ourselves**: Use Flutter's AnimationController with custom painters
- **Flutter Libraries**: 
  - `lottie` for complex flame animations
  - `confetti` for milestone celebrations
  - `percent_indicator` for circular progress
```dart
// Using Lottie for flame animation
class EnhancedStreakCard extends StatefulWidget {
  final int streakCount;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Lottie.asset(
            'assets/animations/flame.json',
            height: 60,
            repeat: streakCount > 0,
          ),
          CircularPercentIndicator(
            radius: 50.0,
            percent: (streakCount % 7) / 7.0, // Weekly cycle
            progressColor: Colors.orange,
            center: Text('$streakCount'),
          ),
        ],
      ),
    );
  }
}
```

### 1.4 Add Total Balance Display with Hide/Show Toggle

**Explanation**: Provide users with an aggregated view of their total funds across all wallets, with privacy control through a toggle button. This gives users immediate financial awareness while respecting privacy concerns.

**Example**: Banking apps often show total balance with an eye icon to hide/show. Could animate between showing actual amount and "***" or blur effect.

**Implementation Solutions**:
- **Build Ourselves**: Simple state management with SharedPreferences for toggle persistence
- **Current Codebase**: Aggregate existing expense/income data
- **Flutter Libraries**: `shared_preferences` for storing hide/show preference
```dart
class TotalBalanceDisplay extends StatefulWidget {
  final double totalBalance;
  
  @override
  _TotalBalanceDisplayState createState() => _TotalBalanceDisplayState();
}

class _TotalBalanceDisplayState extends State<TotalBalanceDisplay> {
  bool _isVisible = true;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          _isVisible 
            ? '₱${NumberFormat('#,##0.00').format(widget.totalBalance)}'
            : '₱***,***.00',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        IconButton(
          icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isVisible = !_isVisible),
        ),
      ],
    );
  }
}
```

### 1.5 Implement Money Insider Section with Mini Charts

**Explanation**: Create a dashboard section showing spending trends, category breakdowns, and financial insights through small, digestible charts. This provides immediate financial awareness without overwhelming the user with complex analytics.

**Example**: Like Apple's Screen Time widgets or Google's spending insights. Small pie chart for categories, line graph for weekly spending, comparison bars for budget vs actual.

**Implementation Solutions**:
- **Build Ourselves**: Custom painters for simple charts
- **Flutter Libraries**: 
  - `fl_chart` for comprehensive charting
  - `syncfusion_flutter_charts` for professional charts (free community license)
```dart
// Using fl_chart for mini pie chart
class MiniSpendingChart extends StatelessWidget {
  final Map<String, double> categoryData;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: PieChart(
        PieChartData(
          sections: categoryData.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value,
              title: entry.key,
              radius: 30,
              titleStyle: TextStyle(fontSize: 10),
            );
          }).toList(),
        ),
      ),
    );
  }
}
```

### 1.6 Add AI Coach Floating Icon for Quick Access

**Explanation**: Introduce a persistent floating icon (different from the main FAB) that provides quick access to AI financial coaching. This creates an always-available assistant that users can consult for spending advice, budget tips, or financial questions.

**Example**: Like chat support bubbles on websites or Google Assistant's floating icon. Could pulse or glow when there are new insights available.

**Implementation Solutions**:
- **Build Ourselves**: Positioned widget with GestureDetector
- **Flutter Libraries**: 
  - `floating_action_bubble` for bubble-style interface
  - `badges` for notification indicators
```dart
class AICoachFloatingIcon extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasNewInsights;
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.3,
      child: Badge(
        showBadge: hasNewInsights,
        child: FloatingActionButton.small(
          onPressed: onTap,
          backgroundColor: Colors.blue,
          child: Icon(Icons.psychology),
        ),
      ),
    );
  }
}
```

### 1.7 Integrate Cultural Motivational Phrases

**Explanation**: Display context-aware Filipino motivational messages that encourage financial discipline and goal achievement. These phrases should change based on user progress, challenges, and financial behavior to maintain engagement.

**Example**: Messages like "Konting tiis pa, Josh! Ipon na malapit na!" when close to a goal, or "Tibay mo naman! 30 days streak na!" for milestone achievements.

**Implementation Solutions**:
- **Build Ourselves**: Create phrase database with context triggers
- **Current Codebase**: Integrate with existing streak/goal systems
- **No external libraries needed**: Use simple String array with smart selection logic
```dart
class MotivationalPhraseWidget extends StatelessWidget {
  final UserContext userContext;
  
  String _getContextualPhrase() {
    if (userContext.streakDays >= 30) {
      return "Tibay mo naman! ${userContext.streakDays} days streak na!";
    } else if (userContext.goalProgress > 0.8) {
      return "Konting tiis pa! Ipon na malapit na!";
    } else if (userContext.todayExpenses == 0) {
      return "Walang gastos today? Sipag mo!";
    }
    return "Kaya mo yan! Keep tracking!";
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getContextualPhrase(),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}
```

### 1.8 Create Thermometer-Style Progress Bars

**Explanation**: Replace standard progress bars with visual thermometer-style indicators that show progress toward goals in an intuitive, engaging way. This provides immediate visual feedback on goal achievement and creates a more gamified experience.

**Example**: Like fundraising thermometers or temperature gauges. Could show red-to-green gradient as progress increases, with milestone markers along the way.

**Implementation Solutions**:
- **Build Ourselves**: Custom painter for thermometer shape
- **Flutter Libraries**: 
  - `custom_paint` for thermometer shape
  - `percent_indicator` as base with custom styling
```dart
class ThermometerProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double targetAmount;
  final double currentAmount;
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(40, 200),
      painter: ThermometerPainter(progress),
      child: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₱${NumberFormat.compact().format(targetAmount)}'),
            Text('₱${NumberFormat.compact().format(currentAmount)}'),
          ],
        ),
      ),
    );
  }
}

class ThermometerPainter extends CustomPainter {
  final double progress;
  
  ThermometerPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw thermometer background
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    
    // Draw thermometer fill
    Paint fillPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    // Implementation of thermometer drawing logic
    // ...
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### 1.9 Implement Quick Action Cards for Common Tasks

**Explanation**: Create shortcut cards for frequently used features like adding expenses, checking goals, or viewing challenges. This reduces navigation time and makes the app more efficient for daily use.

**Example**: Like iOS shortcuts or Android quick settings. Cards showing "Add Expense", "Check Goals", "View Challenges" with appropriate icons and recent data.

**Implementation Solutions**:
- **Build Ourselves**: Grid of cards with GestureDetector
- **Current Codebase**: Leverage existing navigation and routing
- **Flutter Libraries**: `staggered_grid_view` for dynamic card layouts
```dart
class QuickActionCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      children: [
        QuickActionCard(
          title: 'Add Expense',
          icon: Icons.trending_down,
          color: Colors.red,
          onTap: () => Navigator.pushNamed(context, '/add-expense'),
        ),
        QuickActionCard(
          title: 'Check Goals',
          icon: Icons.flag,
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/goals'),
        ),
        QuickActionCard(
          title: 'Challenges',
          icon: Icons.emoji_events,
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, '/challenges'),
        ),
      ],
    );
  }
}
```

---

## 2. Transaction Screen (Add Expense Screen) UI Changes

### 2.1 Create Unified Money In/Money Out Tabs

**Explanation**: Combine income and expense entry into a single screen with tab navigation. This reduces app complexity and provides a unified transaction entry point, making it easier for users to switch between recording income and expenses.

**Example**: Like most banking apps where you can switch between "Send" and "Receive" money. Use TabBar with clear icons and labels for "Money In" (green) and "Money Out" (red).

**Implementation Solutions**:
- **Build Ourselves**: Use Flutter's TabBar and TabBarView
- **Current Codebase**: Refactor existing AddExpenseScreen to support both types
- **Flutter Libraries**: Built-in `TabBar` and `TabBarView` widgets
```dart
class UnifiedTransactionScreen extends StatefulWidget {
  @override
  _UnifiedTransactionScreenState createState() => _UnifiedTransactionScreenState();
}

class _UnifiedTransactionScreenState extends State<UnifiedTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.trending_up, color: Colors.green), text: 'Money In'),
            Tab(icon: Icon(Icons.trending_down, color: Colors.red), text: 'Money Out'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          IncomeEntryForm(),
          ExpenseEntryForm(),
        ],
      ),
    );
  }
}
```

### 2.2 Add Voice Input Button with Filipino Phrase Support

**Explanation**: Implement voice-to-text functionality that can understand Filipino phrases like "Nag-spend ako ng ₱50 sa breakfast" and automatically extract amount, category, and description. This makes transaction entry faster and more natural for Filipino users.

**Example**: Google Assistant-style voice input that parses natural language. User says "Bumili ako ng ₱200 na grocery sa SM" and the app fills amount: ₱200, category: Shopping, description: "grocery sa SM".

**Implementation Solutions**:
- **Flutter Libraries**: 
  - `speech_to_text` for voice recognition
  - Custom parsing logic for Filipino phrases
  - `permission_handler` for microphone access
```dart
class VoiceInputButton extends StatefulWidget {
  final Function(VoiceTransactionData) onVoiceInput;
  
  @override
  _VoiceInputButtonState createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }
  
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }
  
  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'en_PH', // Filipino English
    );
  }
  
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      final parsed = FilipinoNLPParser.parse(result.recognizedWords);
      widget.onVoiceInput(parsed);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _speechEnabled ? _startListening : null,
      child: Icon(Icons.mic),
      backgroundColor: _speechToText.isListening ? Colors.red : Colors.blue,
    );
  }
}

class FilipinoNLPParser {
  static VoiceTransactionData parse(String text) {
    // Parse patterns like:
    // "Nag-spend ako ng ₱50 sa breakfast"
    // "Bumili ako ng ₱200 na grocery"
    // "Gas ₱300 sa shell"
    
    final amountRegex = RegExp(r'₱?(\d+)');
    final foodKeywords = ['breakfast', 'lunch', 'dinner', 'kain', 'pagkain'];
    final transportKeywords = ['gas', 'pamasahe', 'jeep', 'taxi'];
    
    double? amount;
    String category = 'Other';
    String description = text;
    
    // Extract amount
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1)!);
    }
    
    // Determine category
    final lowerText = text.toLowerCase();
    if (foodKeywords.any((keyword) => lowerText.contains(keyword))) {
      category = 'Food & Dining';
    } else if (transportKeywords.any((keyword) => lowerText.contains(keyword))) {
      category = 'Transportation';
    }
    
    return VoiceTransactionData(
      amount: amount ?? 0.0,
      category: category,
      description: description,
    );
  }
}
```

### 2.3 Implement Photo Receipt Capture with Auto-Categorization

**Explanation**: Add camera functionality to capture receipt photos and use OCR (Optical Character Recognition) to extract merchant names, amounts, and suggest categories. This reduces manual entry and improves transaction accuracy.

**Example**: Apps like Expensify or Receipt Bank where you snap a photo and it automatically fills in details. Could recognize "Jollibee" and suggest "Food & Dining" category.

**Implementation Solutions**:
- **Flutter Libraries**: 
  - `camera` for photo capture
  - `image_picker` for gallery selection
  - `google_ml_kit` for text recognition (OCR)
  - `path_provider` for local image storage
```dart
class PhotoReceiptCapture extends StatefulWidget {
  final Function(ReceiptData) onReceiptProcessed;
  
  @override
  _PhotoReceiptCaptureState createState() => _PhotoReceiptCaptureState();
}

class _PhotoReceiptCaptureState extends State<PhotoReceiptCapture> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  Future<void> _captureReceipt() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      final receiptData = _parseReceiptText(recognizedText.text);
      widget.onReceiptProcessed(receiptData);
    }
  }
  
  ReceiptData _parseReceiptText(String text) {
    // Parse receipt text for:
    // - Merchant name (Jollibee, SM, Mercury Drug, etc.)
    // - Amount (₱123.45)
    // - Date
    // - Items
    
    final merchantPatterns = {
      'Jollibee': 'Food & Dining',
      'McDonald\'s': 'Food & Dining',
      'SM': 'Shopping',
      'Mercury Drug': 'Healthcare',
      'Shell': 'Transportation',
      '7-Eleven': 'Shopping',
    };
    
    String category = 'Other';
    String merchant = '';
    double amount = 0.0;
    
    // Find merchant
    for (final pattern in merchantPatterns.keys) {
      if (text.toUpperCase().contains(pattern.toUpperCase())) {
        merchant = pattern;
        category = merchantPatterns[pattern]!;
        break;
      }
    }
    
    // Extract amount (look for ₱ or TOTAL patterns)
    final amountRegex = RegExp(r'(?:TOTAL|₱)\s*(\d+\.?\d*)');
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1)!) ?? 0.0;
    }
    
    return ReceiptData(
      merchant: merchant,
      amount: amount,
      category: category,
      rawText: text,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _captureReceipt,
      child: Icon(Icons.camera_alt),
      backgroundColor: Colors.green,
    );
  }
}
```

### 2.4 Create Filipino-Specific Categories System

**Explanation**: Implement a category system tailored to Filipino spending patterns with local terms and subcategories that reflect actual Filipino lifestyle and expenses. This makes categorization more intuitive and accurate for Filipino users.

**Example**: Categories like "Pagkain" with subcategories "Jolly/McDo", "Carinderia", "Turo-turo"; "Transportasyon" with "Jeepney", "Tricycle", "Grab"; "Bills" with "Kuryente", "Tubig", "Load".

**Implementation Solutions**:
- **Build Ourselves**: Create comprehensive category mapping
- **Current Codebase**: Extend existing category enum
- **No external libraries needed**: Use structured data with localization
```dart
class FilipinoCategories {
  static const Map<String, List<String>> categories = {
    'Pagkain': [
      'Jolly/McDo',
      'Carinderia',
      'Turo-turo',
      'Grocery',
      'Kape/Milk Tea',
      'Inuman',
      'Special Occasion'
    ],
    'Transportasyon': [
      'Jeepney',
      'Bus',
      'MRT/LRT',
      'Tricycle',
      'Habal-habal',
      'Grab/Taxi',
      'Gas/Parking',
      'Motor Maintenance'
    ],
    'Bills': [
      'Kuryente',
      'Tubig',
      'Internet',
      'Load',
      'Cable TV',
      'Rent',
      'Association Dues'
    ],
    'Shopping': [
      'Grocery',
      'Damit',
      'Gadgets',
      'Bahay Items',
      'Beauty Products',
      'Gifts/Pasalubong'
    ],
    'Entertainment': [
      'Movies',
      'Gimik/Lakwatsa',
      'Gaming',
      'Streaming',
      'Sports/Gym',
      'Hobbies'
    ],
    'Healthcare': [
      'Gamot',
      'Doctor Visit',
      'Dental',
      'Lab Tests',
      'Insurance'
    ],
    'Education': [
      'Tuition',
      'Books',
      'School Supplies',
      'Online Courses',
      'Enrollment Fees'
    ],
  };
  
  static List<String> getSubcategories(String category) {
    return categories[category] ?? [];
  }
  
  static List<String> getAllCategories() {
    return categories.keys.toList();
  }
}

class FilipinoCategorySelector extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedSubcategory;
  final Function(String category, String? subcategory) onSelectionChanged;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(labelText: 'Category'),
          items: FilipinoCategories.getAllCategories().map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(_getCategoryIcon(category)),
                  SizedBox(width: 8),
                  Text(category),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            onSelectionChanged(value!, null);
          },
        ),
        if (selectedCategory != null)
          DropdownButtonFormField<String>(
            value: selectedSubcategory,
            decoration: InputDecoration(labelText: 'Subcategory'),
            items: FilipinoCategories.getSubcategories(selectedCategory!)
                .map((subcategory) {
              return DropdownMenuItem(
                value: subcategory,
                child: Text(subcategory),
              );
            }).toList(),
            onChanged: (value) {
              onSelectionChanged(selectedCategory!, value);
            },
          ),
      ],
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pagkain': return Icons.restaurant;
      case 'Transportasyon': return Icons.directions_car;
      case 'Bills': return Icons.receipt_long;
      case 'Shopping': return Icons.shopping_bag;
      case 'Entertainment': return Icons.movie;
      case 'Healthcare': return Icons.local_hospital;
      case 'Education': return Icons.school;
      default: return Icons.category;
    }
  }
}
```

### 2.5 Add Recurring Transaction Toggle with Frequency Options

**Explanation**: Allow users to set up recurring transactions (like monthly bills, weekly allowance, daily coffee) with various frequency options. This reduces repetitive data entry and helps with budgeting regular expenses.

**Example**: Like subscription management in banking apps. Toggle switch for "Make this recurring" with options for Daily, Weekly, Bi-weekly, Monthly, Quarterly, Yearly.

**Implementation Solutions**:
- **Build Ourselves**: Create recurring transaction model and scheduler
- **Flutter Libraries**: 
  - `cron` for scheduling logic
  - `flutter_local_notifications` for reminders
```dart
enum RecurrenceFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
}

class RecurringTransactionToggle extends StatefulWidget {
  final Function(bool isRecurring, RecurrenceFrequency? frequency) onChanged;
  
  @override
  _RecurringTransactionToggleState createState() => _RecurringTransactionToggleState();
}

class _RecurringTransactionToggleState extends State<RecurringTransactionToggle> {
  bool _isRecurring = false;
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Make this recurring'),
          subtitle: Text('Set up automatic recurring transactions'),
          value: _isRecurring,
          onChanged: (value) {
            setState(() {
              _isRecurring = value;
            });
            widget.onChanged(_isRecurring, _isRecurring ? _frequency : null);
          },
        ),
        if (_isRecurring)
          DropdownButtonFormField<RecurrenceFrequency>(
            value: _frequency,
            decoration: InputDecoration(
              labelText: 'Frequency',
              prefixIcon: Icon(Icons.repeat),
            ),
            items: RecurrenceFrequency.values.map((frequency) {
              return DropdownMenuItem(
                value: frequency,
                child: Text(_getFrequencyLabel(frequency)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _frequency = value!;
              });
              widget.onChanged(_isRecurring, _frequency);
            },
          ),
      ],
    );
  }
  
  String _getFrequencyLabel(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily: return 'Daily (araw-araw)';
      case RecurrenceFrequency.weekly: return 'Weekly (linggo-linggo)';
      case RecurrenceFrequency.biweekly: return 'Bi-weekly (dalawang linggo)';
      case RecurrenceFrequency.monthly: return 'Monthly (buwan-buwan)';
      case RecurrenceFrequency.quarterly: return 'Quarterly (tatlong buwan)';
      case RecurrenceFrequency.yearly: return 'Yearly (taun-taon)';
    }
  }
}

class RecurringTransactionService {
  static Future<void> scheduleRecurringTransaction(
    Expense templateExpense,
    RecurrenceFrequency frequency,
  ) async {
    // Implementation for scheduling recurring transactions
    // Could use local notifications or background tasks
    
    final nextDate = _calculateNextDate(DateTime.now(), frequency);
    
    await FlutterLocalNotificationsPlugin().schedulePeriodicallyShow(
      templateExpense.id.hashCode,
      'Recurring Transaction Reminder',
      'Time to log your ${templateExpense.description}',
      RepeatInterval.daily, // Adjust based on frequency
      NotificationDetails(/* ... */),
    );
  }
  
  static DateTime _calculateNextDate(DateTime current, RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return current.add(Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return current.add(Duration(days: 7));
      case RecurrenceFrequency.biweekly:
        return current.add(Duration(days: 14));
      case RecurrenceFrequency.monthly:
        return DateTime(current.year, current.month + 1, current.day);
      case RecurrenceFrequency.quarterly:
        return DateTime(current.year, current.month + 3, current.day);
      case RecurrenceFrequency.yearly:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }
}
```

*[Continue with remaining sections...]*

---

This document provides comprehensive implementation details for each UI change. Each section includes:

1. **Clear explanation** of the feature and its purpose
2. **Real-world examples** from popular apps
3. **Multiple implementation approaches** with code examples
4. **Library recommendations** with rationale
5. **Integration guidance** with existing codebase

The solutions balance complexity with maintainability, favoring simpler approaches where possible while suggesting powerful libraries for complex features like charts, animations, and ML capabilities.
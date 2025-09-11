# IponGPT Style Implementation Details

## Overview
This document provides comprehensive technical implementation details for the IponGPT Visual Design & Styling System. It covers the complete design token system, component specifications, cultural design patterns, and practical implementation guidelines with code examples.

---

## 1. Color System Implementation

### Color Palette Structure
```dart
// IponGPT Color System - colors.dart
class IponColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color warningRed = Color(0xFFF44336);
  
  // Secondary Colors
  static const Color warmYellow = Color(0xFFFFC107);
  static const Color purple = Color(0xFF9C27B0);
  static const Color teal = Color(0xFF009688);
  static const Color indigo = Color(0xFF3F51B5);
  
  // Neutral Colors
  static const Color darkGray = Color(0xFF424242);
  static const Color mediumGray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFBDBDBD);
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Cultural Colors
  static const Color sunsetOrange = Color(0xFFFF7043);
  static const Color oceanBlue = Color(0xFF0288D1);
  static const Color riceGold = Color(0xFFFFB300);
  static const Color bambooGreen = Color(0xFF388E3C);
  
  // Generated Color Swatches
  static MaterialColor get primarySwatch => MaterialColor(0xFF4CAF50, {
    50: Color(0xFFE8F5E8),
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(0xFF4CAF50),
    600: Color(0xFF43A047),
    700: Color(0xFF388E3C),
    800: Color(0xFF2E7D32),
    900: Color(0xFF1B5E20),
  });
}
```

### Dynamic Color Schemes
```dart
// Dynamic color scheme generation
class IponColorScheme {
  static ColorScheme light() => ColorScheme.fromSeed(
    seedColor: IponColors.primaryGreen,
    brightness: Brightness.light,
    primary: IponColors.primaryGreen,
    secondary: IponColors.accentOrange,
    tertiary: IponColors.teal,
    error: IponColors.warningRed,
    surface: IponColors.cardBackground,
    background: IponColors.background,
  );
  
  static ColorScheme dark() => ColorScheme.fromSeed(
    seedColor: IponColors.primaryGreen,
    brightness: Brightness.dark,
    primary: Color(0xFF66BB6A), // Lighter green for dark mode
    secondary: Color(0xFFFFCC02), // Brighter orange for dark mode
    tertiary: Color(0xFF26A69A), // Lighter teal for dark mode
    error: Color(0xFFEF5350), // Lighter red for dark mode
  );
  
  // Cultural theme variants
  static ColorScheme festival() => ColorScheme.fromSeed(
    seedColor: IponColors.riceGold,
    brightness: Brightness.light,
    primary: IponColors.riceGold,
    secondary: IponColors.sunsetOrange,
    tertiary: IponColors.oceanBlue,
  );
}
```

### Category Color Mapping
```dart
// Category-specific color assignments
enum ExpenseCategory {
  food(IponColors.accentOrange, Icons.restaurant),
  transportation(IponColors.primaryBlue, Icons.directions_bus),
  shopping(IponColors.purple, Icons.shopping_bag),
  bills(IponColors.warningRed, Icons.receipt_long),
  healthcare(IponColors.teal, Icons.local_hospital),
  entertainment(IponColors.warmYellow, Icons.movie),
  education(IponColors.indigo, Icons.school);
  
  const ExpenseCategory(this.color, this.icon);
  final Color color;
  final IconData icon;
}

// Usage in widgets
Container(
  decoration: BoxDecoration(
    color: category.color.withOpacity(0.1),
    border: Border.all(color: category.color, width: 1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(category.icon, color: category.color),
)
```

---

## 2. Typography System Implementation

### Font Configuration
```dart
// Typography system - typography.dart
class IponTypography {
  // Font family definitions
  static const String primaryFont = 'Inter';
  static const String secondaryFont = 'Nunito Sans';
  static const String displayFont = 'Poppins';
  static const String monospaceFont = 'JetBrains Mono';
  
  // Text style definitions
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.15,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.43,
    letterSpacing: 0.25,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );
  
  // Filipino-specific text styles
  static const TextStyle tagalogFriendly = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.6, // Extra line height for mixed languages
    letterSpacing: 0.2,
  );
  
  // Peso currency formatting
  static const TextStyle currencyLarge = TextStyle(
    fontFamily: monospaceFont,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle currencySmall = TextStyle(
    fontFamily: monospaceFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );
}
```

### Text Theme Integration
```dart
// Custom TextTheme for IponGPT
TextTheme iponTextTheme() => TextTheme(
  displayLarge: IponTypography.displayLarge,
  displayMedium: IponTypography.displayLarge.copyWith(fontSize: 28),
  displaySmall: IponTypography.displayLarge.copyWith(fontSize: 24),
  headlineLarge: IponTypography.headlineMedium.copyWith(fontSize: 28),
  headlineMedium: IponTypography.headlineMedium,
  headlineSmall: IponTypography.headlineMedium.copyWith(fontSize: 20),
  titleLarge: IponTypography.titleMedium.copyWith(fontSize: 22),
  titleMedium: IponTypography.titleMedium,
  titleSmall: IponTypography.titleMedium.copyWith(fontSize: 18),
  bodyLarge: IponTypography.bodyLarge,
  bodyMedium: IponTypography.bodyMedium,
  bodySmall: IponTypography.bodyMedium.copyWith(fontSize: 12),
  labelLarge: IponTypography.labelMedium.copyWith(fontSize: 14),
  labelMedium: IponTypography.labelMedium,
  labelSmall: IponTypography.labelMedium.copyWith(fontSize: 10),
);
```

### Filipino Text Handling
```dart
// Filipino text utilities
class FilipinoTextUtils {
  static bool isTagalog(String text) {
    // Common Filipino words for detection
    final filipinoWords = [
      'ang', 'ng', 'sa', 'mga', 'ay', 'at', 'na', 'para', 'ako', 'ka',
      'pagkain', 'transportasyon', 'gastos', 'pera', 'ipon', 'bayad'
    ];
    
    return filipinoWords.any((word) => 
      text.toLowerCase().contains(word.toLowerCase())
    );
  }
  
  static TextStyle getTextStyle(String text) {
    return isTagalog(text) 
      ? IponTypography.tagalogFriendly 
      : IponTypography.bodyLarge;
  }
  
  // Currency formatting for Philippines
  static String formatPeso(double amount) {
    return '₱${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    )}';
  }
  
  // Handle long category names
  static String truncateCategory(String category, int maxLength) {
    if (category.length <= maxLength) return category;
    return '${category.substring(0, maxLength - 3)}...';
  }
}
```

---

## 3. Iconography System Implementation

### Custom Icon Assets
```dart
// Custom Filipino icons - filipino_icons.dart
class FilipinoIcons {
  static const IconData jeepney = IconData(0xe800, fontFamily: 'FilipinoIcons');
  static const IconData sariSariStore = IconData(0xe801, fontFamily: 'FilipinoIcons');
  static const IconData bahayKubo = IconData(0xe802, fontFamily: 'FilipinoIcons');
  static const IconData bangus = IconData(0xe803, fontFamily: 'FilipinoIcons');
  static const IconData coconut = IconData(0xe804, fontFamily: 'FilipinoIcons');
  static const IconData tricycle = IconData(0xe805, fontFamily: 'FilipinoIcons');
  static const IconData karaoke = IconData(0xe806, fontFamily: 'FilipinoIcons');
  static const IconData palay = IconData(0xe807, fontFamily: 'FilipinoIcons');
  
  // Flag colors for achievements
  static const Color flagBlue = Color(0xFF0038A8);
  static const Color flagRed = Color(0xFFCE1126);
  static const Color flagYellow = Color(0xFFFCE02A);
}
```

### Icon Component System
```dart
// Standardized icon component
class IponIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final bool isFilipino;
  
  const IponIcon(
    this.icon, {
    this.size = 24,
    this.color,
    this.isFilipino = false,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? (isFilipino 
        ? FilipinoIcons.flagBlue 
        : Theme.of(context).iconTheme.color),
    );
  }
}

// Category icon selector
class CategoryIcon extends StatelessWidget {
  final ExpenseCategory category;
  final double size;
  final bool showBackground;
  
  const CategoryIcon({
    required this.category,
    this.size = 24,
    this.showBackground = false,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final icon = IponIcon(
      category.icon,
      size: size,
      color: category.color,
    );
    
    if (!showBackground) return icon;
    
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: category.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(child: icon),
    );
  }
}
```

### Asset Organization System
```yaml
# pubspec.yaml - Asset configuration
flutter:
  assets:
    - assets/icons/categories/
    - assets/icons/filipino/
    - assets/icons/ui/
    - assets/images/illustrations/
    - assets/images/backgrounds/
    - assets/images/achievements/
    - assets/animations/lottie/
    - assets/animations/rive/
  
  fonts:
    - family: FilipinoIcons
      fonts:
        - asset: fonts/FilipinoIcons.ttf
    - family: Inter
      fonts:
        - asset: fonts/Inter-Regular.ttf
        - asset: fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: fonts/Inter-Bold.ttf
          weight: 700
    - family: Poppins
      fonts:
        - asset: fonts/Poppins-Bold.ttf
          weight: 700
    - family: JetBrains Mono
      fonts:
        - asset: fonts/JetBrainsMono-Regular.ttf
        - asset: fonts/JetBrainsMono-SemiBold.ttf
          weight: 600
```

---

## 4. Visual Components Implementation

### Design Token System
```dart
// Design tokens - tokens.dart
class IponTokens {
  // Spacing scale
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  
  // Corner radius
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;
  
  // Elevation levels
  static const double elevation0 = 0.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
  
  // Touch targets
  static const double touchTarget40 = 40.0;
  static const double touchTarget44 = 44.0;
  static const double touchTarget48 = 48.0;
  static const double touchTarget56 = 56.0;
}
```

### Card Components
```dart
// Standardized card component
class IponCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double elevation;
  final bool hasBorder;
  
  const IponCard({
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.elevation = IponTokens.elevation2,
    this.hasBorder = false,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IponTokens.radius12),
        side: hasBorder 
          ? BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
              width: 1,
            )
          : BorderSide.none,
      ),
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IponTokens.radius12),
        child: Padding(
          padding: padding ?? EdgeInsets.all(IponTokens.space16),
          child: child,
        ),
      ),
    );
  }
}

// Expense card with Filipino styling
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final bool showReceipt;
  
  const ExpenseCard({
    required this.expense,
    this.onTap,
    this.showReceipt = false,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return IponCard(
      onTap: onTap,
      child: Row(
        children: [
          CategoryIcon(
            category: expense.category,
            size: 32,
            showBackground: true,
          ),
          SizedBox(width: IponTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: FilipinoTextUtils.getTextStyle(expense.description),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: IponTokens.space4),
                Text(
                  expense.category.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: expense.category.color,
                  ),
                ),
              ],
            ),
          ),
          if (showReceipt && expense.receiptPath != null) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IponTokens.radius4),
                image: DecorationImage(
                  image: FileImage(File(expense.receiptPath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: IponTokens.space8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FilipinoTextUtils.formatPeso(expense.amount),
                style: IponTypography.currencySmall.copyWith(
                  color: expense.category.color,
                ),
              ),
              SizedBox(height: IponTokens.space4),
              Text(
                DateFormat('MMM dd').format(expense.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Progress Indicators
```dart
// Thermometer-style progress bar
class ThermometerProgress extends StatefulWidget {
  final double progress;
  final double targetAmount;
  final double currentAmount;
  final Color? progressColor;
  final String? goalName;
  
  const ThermometerProgress({
    required this.progress,
    required this.targetAmount,
    required this.currentAmount,
    this.progressColor,
    this.goalName,
    Key? key,
  }) : super(key: key);
  
  @override
  State<ThermometerProgress> createState() => _ThermometerProgressState();
}

class _ThermometerProgressState extends State<ThermometerProgress>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    final progressColor = widget.progressColor ?? IponColors.primaryGreen;
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IponTokens.radius24),
            border: Border.all(
              color: progressColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(IponTokens.radius24 - 2),
                ),
              ),
              // Progress fill
              FractionallySizedBox(
                heightFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        progressColor,
                        progressColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(IponTokens.radius24 - 2),
                  ),
                ),
              ),
              // Milestone markers
              ...List.generate(5, (index) {
                final markerPosition = (index + 1) * 0.2;
                return Positioned(
                  bottom: (200 - 4) * markerPosition,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 2,
                    color: Theme.of(context).dividerColor,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Filipino-themed circular progress
class BahayKuboProgress extends StatefulWidget {
  final double progress;
  final String label;
  final Color progressColor;
  
  const BahayKuboProgress({
    required this.progress,
    required this.label,
    this.progressColor = const Color(0xFF388E3C),
    Key? key,
  }) : super(key: key);
  
  @override
  State<BahayKuboProgress> createState() => _BahayKuboProgressState();
}

class _BahayKuboProgressState extends State<BahayKuboProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(120, 120),
          painter: BahayKuboProgressPainter(
            progress: widget.progress * _controller.value,
            progressColor: widget.progressColor,
            backgroundColor: widget.progressColor.withOpacity(0.1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IponIcon(
                  FilipinoIcons.bahayKubo,
                  size: 32,
                  color: widget.progressColor,
                  isFilipino: true,
                ),
                SizedBox(height: IponTokens.space4),
                Text(
                  '${(widget.progress * 100).toInt()}%',
                  style: IponTypography.labelMedium.copyWith(
                    color: widget.progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 5. Animation System Implementation

### Animation Constants
```dart
// Animation constants - animations.dart
class IponAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration extraSlow = Duration(milliseconds: 800);
  
  // Curves
  static const Curve bounceIn = Curves.elasticOut;
  static const Curve slideIn = Curves.easeOutCubic;
  static const Curve fadeIn = Curves.easeInOut;
  
  // Scale values
  static const double scaleDown = 0.95;
  static const double scaleUp = 1.05;
}
```

### Micro-Interactions
```dart
// Button press animation
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  
  const AnimatedButton({
    required this.child,
    this.onPressed,
    this.duration = IponAnimations.fast,
    Key? key,
  }) : super(key: key);
  
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: IponAnimations.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: IponAnimations.bounceIn,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Cultural Celebrations
```dart
// Filipino-themed confetti animation
class FilipinoConfetti extends StatefulWidget {
  final bool isActive;
  final Duration duration;
  
  const FilipinoConfetti({
    required this.isActive,
    this.duration = const Duration(seconds: 3),
    Key? key,
  }) : super(key: key);
  
  @override
  State<FilipinoConfetti> createState() => _FilipinoConfettiState();
}

class _FilipinoConfettiState extends State<FilipinoConfetti>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<ConfettiParticle> particles = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    if (widget.isActive) {
      _generateParticles();
      _controller.forward();
    }
  }
  
  void _generateParticles() {
    final random = Random();
    particles = List.generate(50, (index) {
      return ConfettiParticle(
        color: [
          FilipinoIcons.flagBlue,
          FilipinoIcons.flagRed,
          FilipinoIcons.flagYellow,
          IponColors.riceGold,
          IponColors.sunsetOrange,
        ][random.nextInt(5)],
        startX: random.nextDouble(),
        startY: random.nextDouble() * 0.3,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: random.nextDouble() * 0.5 + 0.5,
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * 360,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: particles,
            animationValue: _controller.value,
          ),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Goal completion fireworks
class GoalFireworks extends StatefulWidget {
  final bool isActive;
  final String goalName;
  
  const GoalFireworks({
    required this.isActive,
    required this.goalName,
    Key? key,
  }) : super(key: key);
  
  @override
  State<GoalFireworks> createState() => _GoalFireworksState();
}

class _GoalFireworksState extends State<GoalFireworks>
    with TickerProviderStateMixin {
  late AnimationController _fireworksController;
  late AnimationController _textController;
  
  @override
  void initState() {
    super.initState();
    _fireworksController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _textController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    if (widget.isActive) {
      _startAnimation();
    }
  }
  
  void _startAnimation() async {
    await _textController.forward();
    await _fireworksController.forward();
    await Future.delayed(Duration(seconds: 1));
    await _textController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return SizedBox.shrink();
    
    return Stack(
      children: [
        // Fireworks animation
        AnimatedBuilder(
          animation: _fireworksController,
          builder: (context, child) {
            return CustomPaint(
              painter: FireworksPainter(
                animationValue: _fireworksController.value,
                colors: [
                  FilipinoIcons.flagBlue,
                  FilipinoIcons.flagRed,
                  FilipinoIcons.flagYellow,
                ],
              ),
              size: MediaQuery.of(context).size,
            );
          },
        ),
        // Celebration text
        AnimatedBuilder(
          animation: _textController,
          builder: (context, child) {
            return Transform.scale(
              scale: _textController.value,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(IponTokens.space24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(IponTokens.radius16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Congratulations!',
                        style: IponTypography.displayLarge.copyWith(
                          color: IponColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: IponTokens.space8),
                      Text(
                        'Goal "${widget.goalName}" completed!',
                        style: IponTypography.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: IponTokens.space4),
                      Text(
                        'Ang galing mo! 🎉',
                        style: IponTypography.tagalogFriendly.copyWith(
                          color: IponColors.warmYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _fireworksController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
```

---

## 6. Theme System Implementation

### Main Theme Configuration
```dart
// Main theme configuration - theme.dart
class IponTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: IponColorScheme.light(),
      textTheme: iponTextTheme(),
      fontFamily: IponTypography.primaryFont,
      
      // Card theme
      cardTheme: CardTheme(
        elevation: IponTokens.elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IponTokens.radius12),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: IponTokens.elevation2,
          padding: EdgeInsets.symmetric(
            horizontal: IponTokens.space24,
            vertical: IponTokens.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IponTokens.radius12),
          ),
          minimumSize: Size(0, IponTokens.touchTarget48),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: IponTokens.space24,
            vertical: IponTokens.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IponTokens.radius12),
          ),
          minimumSize: Size(0, IponTokens.touchTarget48),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: IponColors.background,
        contentPadding: EdgeInsets.all(IponTokens.space16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IponTokens.radius12),
          borderSide: BorderSide(
            color: IponColors.lightGray,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IponTokens.radius12),
          borderSide: BorderSide(
            color: IponColors.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IponTokens.radius12),
          borderSide: BorderSide(
            color: IponColors.warningRed,
            width: 1,
          ),
        ),
      ),
      
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: IponTokens.elevation6,
        shape: CircleBorder(),
        backgroundColor: IponColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: IponColors.darkGray,
        titleTextStyle: IponTypography.headlineMedium.copyWith(
          color: IponColors.darkGray,
        ),
        iconTheme: IconThemeData(
          color: IponColors.darkGray,
          size: 24,
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: IponTokens.elevation8,
        backgroundColor: Colors.white,
        selectedItemColor: IponColors.primaryGreen,
        unselectedItemColor: IponColors.mediumGray,
        selectedLabelStyle: IponTypography.labelMedium,
        unselectedLabelStyle: IponTypography.labelMedium,
        showUnselectedLabels: true,
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: IponColors.background,
        selectedColor: IponColors.primaryGreen.withOpacity(0.2),
        labelStyle: IponTypography.bodyMedium,
        padding: EdgeInsets.symmetric(
          horizontal: IponTokens.space12,
          vertical: IponTokens.space8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IponTokens.radius16),
        ),
      ),
    );
  }
  
  static ThemeData dark() {
    final lightTheme = light();
    return lightTheme.copyWith(
      colorScheme: IponColorScheme.dark(),
      scaffoldBackgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
      appBarTheme: lightTheme.appBarTheme.copyWith(
        foregroundColor: Colors.white,
        titleTextStyle: IponTypography.headlineMedium.copyWith(
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
  
  // Cultural festival theme
  static ThemeData festival() {
    final baseTheme = light();
    return baseTheme.copyWith(
      colorScheme: IponColorScheme.festival(),
      primaryColor: IponColors.riceGold,
      floatingActionButtonTheme: baseTheme.floatingActionButtonTheme.copyWith(
        backgroundColor: IponColors.riceGold,
      ),
    );
  }
}
```

### Responsive Design System
```dart
// Responsive design utilities
class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
  
  static EdgeInsetsGeometry getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.all(IponTokens.space16);
    } else if (isTablet(context)) {
      return EdgeInsets.all(IponTokens.space24);
    } else {
      return EdgeInsets.all(IponTokens.space32);
    }
  }
  
  static double getCardMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 400;
    if (isTablet(context)) return double.infinity;
    return double.infinity;
  }
}
```

---

## 7. Accessibility Implementation

### Accessibility Extensions
```dart
// Accessibility utilities - accessibility.dart
class AccessibilityUtils {
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  static double getScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }
  
  static bool isLargeText(BuildContext context) {
    return getScaleFactor(context) > 1.3;
  }
  
  static Duration getAnimationDuration(
    BuildContext context, 
    Duration defaultDuration,
  ) {
    return shouldReduceMotion(context) 
      ? Duration.zero 
      : defaultDuration;
  }
}

// Accessible button component
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final Color? backgroundColor;
  final bool isPrimary;
  
  const AccessibleButton({
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.backgroundColor,
    this.isPrimary = true,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final button = isPrimary
      ? ElevatedButton(
          onPressed: onPressed,
          style: backgroundColor != null
            ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
            : null,
          child: child,
        )
      : OutlinedButton(
          onPressed: onPressed,
          child: child,
        );
    
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}
```

### Color Contrast Utilities
```dart
// Color contrast utilities
class ContrastUtils {
  static double calculateLuminance(Color color) {
    final r = _linearizeColorComponent(color.red);
    final g = _linearizeColorComponent(color.green);
    final b = _linearizeColorComponent(color.blue);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  static double _linearizeColorComponent(int component) {
    final c = component / 255.0;
    return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4);
  }
  
  static double calculateContrastRatio(Color color1, Color color2) {
    final lum1 = calculateLuminance(color1);
    final lum2 = calculateLuminance(color2);
    final lighter = max(lum1, lum2);
    final darker = min(lum1, lum2);
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }
  
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }
  
  static Color getAccessibleTextColor(Color backgroundColor) {
    final whiteContrast = calculateContrastRatio(Colors.white, backgroundColor);
    final blackContrast = calculateContrastRatio(Colors.black, backgroundColor);
    return whiteContrast > blackContrast ? Colors.white : Colors.black;
  }
}
```

---

## 8. Platform-Specific Implementations

### iOS Adaptations
```dart
// iOS-specific styling
class IOSStyleProvider {
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }
  
  static Widget adaptiveButton({
    required Widget child,
    required VoidCallback? onPressed,
    bool isPrimary = true,
  }) {
    return Builder(
      builder: (context) {
        if (isIOS(context)) {
          return CupertinoButton(
            onPressed: onPressed,
            color: isPrimary ? IponColors.primaryGreen : null,
            borderRadius: BorderRadius.circular(IponTokens.radius12),
            child: child,
          );
        }
        return isPrimary
          ? ElevatedButton(onPressed: onPressed, child: child)
          : OutlinedButton(onPressed: onPressed, child: child);
      },
    );
  }
  
  static Widget adaptiveNavigationBar({
    required String title,
    Widget? leading,
    List<Widget>? actions,
  }) {
    return Builder(
      builder: (context) {
        if (isIOS(context)) {
          return CupertinoNavigationBar(
            middle: Text(title),
            leading: leading,
            trailing: actions?.isNotEmpty == true 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              : null,
          );
        }
        return AppBar(
          title: Text(title),
          leading: leading,
          actions: actions,
        );
      },
    );
  }
}
```

### Android Material You Integration
```dart
// Material You dynamic color support
class MaterialYouProvider {
  static bool supportsColorExtraction(BuildContext context) {
    // Check if Android 12+ and dynamic color is available
    return Theme.of(context).colorScheme.primary != 
           Theme.of(context).colorScheme.secondary;
  }
  
  static ColorScheme? getDynamicColorScheme(BuildContext context) {
    // This would integrate with dynamic_color package
    // For now, return null to use default colors
    return null;
  }
  
  static ThemeData adaptToMaterialYou(BuildContext context, ThemeData base) {
    final dynamicColors = getDynamicColorScheme(context);
    if (dynamicColors == null) return base;
    
    return base.copyWith(
      colorScheme: dynamicColors,
      // Adapt IponGPT colors to match system
      primaryColor: dynamicColors.primary,
    );
  }
}
```

---

## 9. Performance Optimizations

### Image Optimization
```dart
// Optimized image loading
class OptimizedImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;
  
  const OptimizedImage({
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        // Performance optimizations
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        // Reduce memory usage for large images
        filterQuality: FilterQuality.low,
      ),
    );
  }
}

// Cached network image for receipts
class CachedReceiptImage extends StatelessWidget {
  final String imagePath;
  final double size;
  
  const CachedReceiptImage({
    required this.imagePath,
    this.size = 50,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(IponTokens.radius8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IponTokens.radius8 - 1),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          cacheWidth: size.toInt() * 2, // 2x for sharp display
          cacheHeight: size.toInt() * 2,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: IponColors.lightGray,
              child: IponIcon(
                Icons.receipt_long,
                size: size * 0.5,
                color: IponColors.mediumGray,
              ),
            );
          },
        ),
      ),
    );
  }
}
```

### Efficient Layouts
```dart
// Optimized list items
class OptimizedExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  
  const OptimizedExpenseListItem({
    required this.expense,
    this.onTap,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Use const widgets where possible
    const iconSize = 24.0;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: IponTokens.space16,
          vertical: IponTokens.space12,
        ),
        child: Row(
          children: [
            // Cache category icon
            SizedBox(
              width: iconSize + 16,
              height: iconSize + 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: expense.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(IponTokens.radius8),
                ),
                child: Icon(
                  expense.category.icon,
                  size: iconSize,
                  color: expense.category.color,
                ),
              ),
            ),
            SizedBox(width: IponTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: IponTokens.space4),
                  Text(
                    expense.category.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  FilipinoTextUtils.formatPeso(expense.amount),
                  style: IponTypography.currencySmall,
                ),
                SizedBox(height: IponTokens.space4),
                Text(
                  DateFormat('MMM dd').format(expense.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 10. Implementation Checklist

### Phase 1: Core Components (Week 1-2)
- [ ] Set up color system and design tokens
- [ ] Implement typography system with Filipino support
- [ ] Create basic card components
- [ ] Set up icon system with custom Filipino icons
- [ ] Configure main theme structure

### Phase 2: Advanced Components (Week 3-4)
- [ ] Implement progress indicators (thermometer, circular)
- [ ] Create animation system and micro-interactions
- [ ] Build cultural celebration animations
- [ ] Set up accessibility utilities
- [ ] Add platform-specific adaptations

### Phase 3: Integration & Polish (Week 5-6)
- [ ] Integrate all components into existing screens
- [ ] Implement responsive design system
- [ ] Add performance optimizations
- [ ] Test accessibility compliance
- [ ] Finalize cultural design elements

### Phase 4: Testing & Refinement (Week 7-8)
- [ ] Conduct usability testing with Filipino users
- [ ] Optimize animations and transitions
- [ ] Ensure color contrast compliance
- [ ] Test on various device sizes
- [ ] Refine cultural authenticity

### Quality Assurance Checklist
- [ ] All colors meet WCAG AA contrast ratios (4.5:1)
- [ ] Filipino text displays correctly with proper spacing
- [ ] Animations respect user accessibility preferences
- [ ] Touch targets meet minimum 44dp requirement
- [ ] Custom icons display correctly across platforms
- [ ] Theme switching works without glitches
- [ ] Cultural elements are authentic and respectful
- [ ] Performance metrics meet targets (< 16ms per frame)

This comprehensive implementation guide ensures the Visual Design & Styling System integrates seamlessly with IponGPT while maintaining cultural authenticity and accessibility standards.
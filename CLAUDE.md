# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PesoTracker is a Filipino financial tracking Flutter application with gamification features. It helps users track expenses, set savings goals, and complete financial challenges while earning badges and maintaining streaks.

## Development Commands

### Core Commands
```bash
# Run the app (Flutter will prompt for platform selection)
flutter run

# Run on specific platform
flutter run -d chrome     # Web browser
flutter run -d android    # Android device/emulator
flutter run -d ios        # iOS device/simulator

# Build for production
flutter build web        # Build for web deployment
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app

# Code generation (for Hive models)
flutter pub run build_runner build --delete-conflicting-outputs

# Static analysis and linting
flutter analyze

# Run tests
flutter test

# Clean build artifacts
flutter clean

# Install dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade
```

### Testing Individual Files
```bash
# Run a specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

## Architecture

### State Management
The app uses **Provider** for state management with the following providers:
- `ExpenseProvider` - Manages expense tracking and calculations
- `GoalProvider` - Handles savings goals and progress tracking
- `GamificationProvider` - Manages achievements, badges, and streaks
- `ChallengeProvider` - Handles financial challenges
- `LocaleProvider` - Manages app localization

### Data Persistence
Uses **Hive** for local storage with these data models:
- `Expense` - Individual expense entries
- `SavingsGoal` - User savings goals
- `UserData` - User profile and settings
- `Challenge` - Financial challenges and achievements

### Navigation
Uses **go_router** for declarative routing. Main routes:
- `/home` - Home dashboard
- `/expenses` - Expense list and management
- `/goals` - Savings goals tracking
- `/challenges` - Gamification challenges

### Project Structure
```
lib/
├── core/                 # Core application services and constants
│   ├── constants/       # App-wide constants
│   └── services/        # Core services (database, navigation, etc.)
├── features/            # Feature modules
│   ├── expense/        # Expense tracking feature
│   ├── goals/          # Savings goals feature
│   ├── gamification/   # Badges and achievements
│   ├── challenge/      # Financial challenges
│   └── home/           # Home dashboard
└── shared/             # Shared components
    ├── models/         # Data models (with Hive adapters)
    ├── providers/      # State management providers
    ├── screens/        # Shared screens
    └── widgets/        # Reusable widgets
```

### Key Services
- `DatabaseService` - Hive database initialization and box management
- `NavigationService` - Centralized navigation using go_router
- `ChallengeService` - Challenge logic and progression
- `CelebrationService` - Achievement celebrations and animations
- `BackupService` - Data backup and restore functionality

## Platform Support
The app is configured for:
- Android (primary)
- iOS
- Web

Note: The app uses web-compatible packages like `universal_html` and `file_picker` for cross-platform support.

## Development Notes

- The app includes database testing in debug mode (see `database_test.dart`)
- Hive adapters are generated using `build_runner` for type-safe data persistence
- The app follows Material Design 3 guidelines
- Assets are organized in `assets/` directory (images, icons, animations, sounds)
# IponGPT

An AI-powered Filipino financial tracking Flutter application with gamification features. PesoTracker helps users track expenses, set savings goals, and complete financial challenges while earning badges and maintaining streaks.

## Features

- **Expense Tracking** - Record and categorize daily expenses with Filipino peso support
- **Savings Goals** - Set and track progress towards financial goals
- **Gamification** - Earn badges, maintain streaks, and complete challenges
- **Financial Challenges** - Participate in money-saving challenges tailored for Filipino users
- **Data Visualization** - Charts and insights for spending patterns
- **Multi-platform** - Runs on Android, iOS, and Web

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Storage**: Hive
- **Navigation**: go_router
- **UI**: Material Design 3

## Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- For iOS development: Xcode (macOS only)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/IponGPT.git
cd IponGPT
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running Locally

### Run on Web
```bash
flutter run -d chrome
```

### Run on Android
```bash
# Connect an Android device or start an emulator
flutter run -d android
```

### Run on iOS (macOS only)
```bash
# Connect an iOS device or start a simulator
flutter run -d ios
```

### Run with Platform Selection
```bash
# Flutter will prompt you to choose a platform
flutter run
```

## Building for Production

### Build for Web
```bash
flutter build web
```

### Build Android APK
```bash
flutter build apk
```

### Build for iOS
```bash
flutter build ios
```

## Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Clean Build Artifacts
```bash
flutter clean
```

## Project Structure

```
lib/
├── core/                 # Core services and constants
│   ├── constants/       # App-wide constants
│   └── services/        # Database, navigation services
├── features/            # Feature modules
│   ├── expense/        # Expense tracking
│   ├── goals/          # Savings goals
│   ├── gamification/   # Badges and achievements
│   ├── challenge/      # Financial challenges
│   └── home/           # Dashboard
└── shared/             # Shared components
    ├── models/         # Data models with Hive
    ├── providers/      # State management
    └── widgets/        # Reusable widgets
```

## Current Status

The application is in active development with the following components completed:
- Core architecture and state management setup
- Hive database integration for local storage
- Expense tracking functionality
- Savings goals management
- Basic gamification system with badges and streaks
- Financial challenges framework
- Material Design 3 UI implementation

## Contributing

This project is currently in development. For contribution guidelines, please contact the maintainers.

## License

[License information to be added]

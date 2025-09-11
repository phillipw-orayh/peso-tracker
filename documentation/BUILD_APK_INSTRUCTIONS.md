# IponGPT APK Build Instructions

## Prerequisites

### 1. Install Android Studio
Download and install Android Studio from: https://developer.android.com/studio

### 2. Install Android SDK
- Open Android Studio
- Go to SDK Manager (Settings > Appearance & Behavior > System Settings > Android SDK)
- Install:
  - Android SDK Platform-Tools
  - Android SDK Build-Tools (latest version)
  - Android API 34 (Android 14)
  - Android API 21 (minimum requirement)

### 3. Set Environment Variables
Add to your `.bashrc` or `.zshrc`:

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
```

## Building the APK

### Debug APK (for testing)
```bash
cd /path/to/IponGPT
flutter build apk --debug
```

### Release APK (for distribution)
```bash
cd /path/to/IponGPT
flutter build apk --release
```

## Output Location
The APK will be generated at:
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

## Installation
Transfer the APK to your Android device and install:
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

Or copy the APK file to your phone and install manually.

## App Details
- **App Name**: IponGPT
- **Package**: com.ipongpt.ipon_gpt
- **Min SDK**: Android 5.0 (API 21)
- **Target SDK**: Android 14 (API 34)

## Features Included in APK
✅ Complete expense tracking system
✅ Filipino categories (Pagkain, Transportasyon, Bills, etc.)
✅ Taglish language support
✅ Local data storage with Hive
✅ Search and filter functionality
✅ Add/Edit/Delete expenses
✅ Beautiful Material Design UI
✅ Offline functionality
✅ Data backup/restore

## Troubleshooting

### Flutter Doctor Issues
Run `flutter doctor` to check for missing dependencies:
```bash
flutter doctor
```

### Android License Issues
Accept Android licenses:
```bash
flutter doctor --android-licenses
```

### Build Errors
Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```
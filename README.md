# Quick Notes Pro

A smart notes application with voice recording capabilities, built with Flutter.

## Features

- Create, edit, and delete notes
- Voice recording and playback
- Dark/Light theme support
- Arabic and English localization
- Premium features via In-App Purchase
- Ad-supported free version

## Requirements

- Flutter SDK 3.7.0 or higher
- Dart SDK 3.7.0 or higher
- Android SDK 24+ (Android 7.0)
- iOS 15.0+

## Setup

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd quick_notes_pro
flutter pub get
```

### 2. Generate Localization Files

```bash
flutter gen-l10n
```

### 3. Generate Hive Adapters

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Configure Icons (Optional)

Replace placeholder icons in `assets/icons/`:
- `app_icon.png` - Main app icon (1024x1024)
- `app_icon_foreground.png` - Android adaptive icon foreground (432x432)
- `splash_icon.png` - Splash screen icon (288x288)

Then run:
```bash
dart run flutter_launcher_icons
```

### 5. Configure AdMob

Update ad unit IDs in `lib/utils/constants.dart` with your production IDs:
- `bannerAdUnitIdAndroid`
- `bannerAdUnitIdIOS`
- `interstitialAdUnitIdAndroid`
- `interstitialAdUnitIdIOS`

Update `GADApplicationIdentifier` in:
- `ios/Runner/Info.plist`
- `android/app/src/main/AndroidManifest.xml`

### 6. Configure In-App Purchase

Update `premiumProductId` in `lib/utils/constants.dart` with your product ID from App Store Connect / Google Play Console.

## Building

### Android

```bash
# Debug
flutter build apk --debug

# Release
flutter build appbundle --release
```

### iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ipa --release
```

## Project Structure

```
lib/
├── l10n/                  # Localization files
│   ├── app_en.arb
│   ├── app_ar.arb
│   └── generated/
├── models/                # Data models
│   └── note_model.dart
├── providers/             # State management
│   ├── notes_provider.dart
│   └── settings_provider.dart
├── screens/               # App screens
│   ├── home_screen.dart
│   ├── note_editor_screen.dart
│   ├── settings_screen.dart
│   └── premium_screen.dart
├── services/              # Business logic
│   ├── database_service.dart
│   ├── audio_service.dart
│   ├── ad_service.dart
│   └── purchase_service.dart
├── utils/                 # Utilities
│   ├── constants.dart
│   └── helpers.dart
├── widgets/               # Reusable widgets
│   ├── note_card.dart
│   ├── audio_recorder_widget.dart
│   └── banner_ad_widget.dart
└── main.dart
```

## License

All rights reserved.

## Contact

For support, email: vip1981.1@gmail.com

---
description: Build obfuscated release APK for production with code protection
---

# Build Obfuscated Release APK

This workflow builds a release APK with code obfuscation enabled to protect your Dart code from reverse-engineering.

## Prerequisites
- Flutter SDK installed and in PATH
- Android SDK configured
- Signing key configured in `android/app/build.gradle` (for release builds)

## Steps

### 1. Ensure you're in the project directory
```powershell
cd d:\ai_ruchi
```

### 2. Clean the build
// turbo
```powershell
flutter clean
```

### 3. Get dependencies
// turbo
```powershell
flutter pub get
```

### 4. Build obfuscated release APK
This command builds the APK with:
- `--obfuscate`: Obfuscates Dart code to make it harder to reverse-engineer
- `--split-debug-info`: Saves debug symbols separately (required for obfuscation)

```powershell
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

### 5. The output files will be:
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Debug info**: `./debug-info/` folder (keep this for crash symbolication!)

## Important Notes

### Debug Info Folder
⚠️ **KEEP THE `debug-info` FOLDER SAFE!**
- Required for symbolifying crash reports
- Store it with your release version
- Add to `.gitignore` if not needed in repo

### Building App Bundle for Play Store
For Google Play Store, use App Bundle instead:
```powershell
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Split APKs by ABI (smaller file size)
To build separate APKs for different CPU architectures:
```powershell
flutter build apk --release --obfuscate --split-debug-info=./debug-info --split-per-abi
```
This creates separate APKs for:
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit)
- `app-x86_64-release.apk` (x86 64-bit)

## Security Benefits of Obfuscation
1. **Harder to reverse-engineer**: Class, method, and variable names are replaced with meaningless symbols
2. **Protects business logic**: Makes it difficult to understand your app's algorithms
3. **Reduces APK analysis**: Prevents easy extraction of strings and logic

## Adding to Release Checklist
- [ ] Update version in `pubspec.yaml`
- [ ] Ensure `.env` has production values
- [ ] Run `flutter clean`
- [ ] Build with obfuscation
- [ ] Archive `debug-info` folder
- [ ] Test APK on device before release

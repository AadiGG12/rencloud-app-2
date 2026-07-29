#!/bin/bash
set -e

echo "=== RenCloud Android APK Builder ==="
export ANDROID_HOME=/root/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

FLUTTER_CMD="/root/flutter/bin/flutter"
if [ ! -f "$FLUTTER_CMD" ]; then
  FLUTTER_CMD="flutter"
fi

echo "1. Configuring Flutter Android SDK path..."
$FLUTTER_CMD config --android-sdk /root/android-sdk

echo "2. Fetching dependencies..."
$FLUTTER_CMD pub get

echo "3. Building Release APK..."
$FLUTTER_CMD build apk --release --android-skip-build-dependency-validation

echo "=== BUILD COMPLETE! ==="
echo "APK Location: build/app/outputs/flutter-apk/app-release.apk"

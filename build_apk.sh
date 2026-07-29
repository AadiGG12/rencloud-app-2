#!/bin/bash
set -e

echo "=== RenCloud Android APK Builder ==="
FLUTTER_CMD="/root/flutter/bin/flutter"

if [ ! -f "$FLUTTER_CMD" ]; then
  FLUTTER_CMD="flutter"
fi

echo "1. Fetching dependencies..."
$FLUTTER_CMD pub get

echo "2. Building Release APK..."
$FLUTTER_CMD build apk --release

echo "=== BUILD COMPLETE! ==="
echo "APK Location: build/app/outputs/flutter-apk/app-release.apk"

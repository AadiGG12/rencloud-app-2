#!/bin/bash
set -e

echo "=== RenCloud Kotlin Jetpack Compose APK Builder ==="

export ANDROID_HOME="/root/android-sdk"
export ANDROID_SDK_ROOT="/root/android-sdk"
export PATH="/root/gradle-8.5/bin:$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

cd /root/rencloud_android

if [ ! -f "gradlew" ]; then
    echo "1. Initializing Gradle Wrapper..."
    gradle wrapper --gradle-version 8.5
fi

chmod +x gradlew

echo "2. Building Release APK with Jetpack Compose..."
./gradlew assembleRelease --no-daemon

echo "=== BUILD COMPLETE! ==="
echo "APK Location: /root/rencloud_android/app/build/outputs/apk/release/app-release-unsigned.apk"

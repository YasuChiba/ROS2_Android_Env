#!/bin/sh
set -e

# Android SDK, NDKのインストール



ANDROID_NDK_VERSION=android-ndk-r21b
ANDROID_SDK_VERSION=3859397 #6200805
export ANDROID_SDK=/opt/android/android-sdk-linux
export ANDROID_HOME=/opt/android/android-sdk-linux

ANDROID_TARGET=android-21
ANDROID_ABI=arm64-v8a






#NDK, SDK
wget -O /tmp/android-ndk.zip https://dl.google.com/android/repository/${ANDROID_NDK_VERSION}-linux-x86_64.zip && mkdir -p /opt/android/ && cd /opt/android/ && unzip -q /tmp/android-ndk.zip && rm /tmp/android-ndk.zip
wget -O /tmp/android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && mkdir -p /opt/android/android-sdk-linux && cd /opt/android/android-sdk-linux && unzip -q /tmp/android-sdk.zip && rm /tmp/android-sdk.zip



# Accept licenses
yes | ${ANDROID_SDK}/tools/bin/sdkmanager --licenses

# Install platform tools
yes | ${ANDROID_SDK}/tools/bin/sdkmanager --verbose "platform-tools" "platforms;${ANDROID_TARGET}"


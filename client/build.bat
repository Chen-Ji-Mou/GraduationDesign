@echo off

set ROOT_PATH=%~dp0
set APK_PATH=%ROOT_PATH%apk

call flutter build apk --target-platform android-arm64 --split-per-abi

if exist %APK_PATH% rmdir /s /q %APK_PATH%
mkdir %APK_PATH%

cd %ROOt_PATH%build\app\outputs\flutter-apk

copy app-arm64-v8a-release.apk %APK_PATH%\

cd %APK_PATH%

rename %APK_PATH%\app-arm64-v8a-release.apk app-release.apk
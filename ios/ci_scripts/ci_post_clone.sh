#!/bin/sh
# Xcode Cloud runs this after cloning. Flutter's iOS build needs files the repo
# doesn't commit — ios/Flutter/Generated.xcconfig (from `flutter pub get`) and
# the Pods target-support files (from `pod install`) — so produce them here.
set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get

HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
cd ios && pod install

exit 0

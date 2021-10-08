#!/bin/bash


echo "Cleaning project cashed, builds, locks"
flutter clean
rm -rf .flutter-plugins
rm -rf .packages
rm -rf build/
rm -rf ios/Podfile.lock
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

echo "Cleaning Flutter staff"
rm -rf ~/.pub-cache

echo "Cleaning XCode staff"

rm -rf ~/Library/Developer/Xcode/DerivedData

echo "Downloading packages back"

flutter packages get

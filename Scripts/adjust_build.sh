#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Go to root folder
cd ..

# Clean the folders
rm -rf Frameworks/Static
rm -rf Frameworks/Dynamic

# Create needed folders
mkdir -p Frameworks/Static
mkdir -p Frameworks/Dynamic

# Build static AdjustSdk.framework
xcodebuild -target AdjustStatic -configuration Release

# Build dynamic AdjustSdk.framework
xcodebuild -target AdjustSdk -configuration Release

# Build Carthage AdjustSdk.framework
carthage build --no-skip-current

# Copy build Carthage framework to Frameworks folder
cp -R Carthage/Build/iOS/* Frameworks/Dynamic/

# Copy static framework into example iOS app
rm -rf examples/AdjustExample-iOS/AdjustExample-iOS/Adjust/AdjustSdk.framework
cp -R Frameworks/Static/AdjustSdk.framework examples/AdjustExample-iOS/AdjustExample-iOS/Adjust/

# Copy static framework into example Swift app
rm -rf examples/AdjustExample-Swift/AdjustExample-Swift/Adjust/AdjustSdk.framework
cp -R Frameworks/Static/AdjustSdk.framework examples/AdjustExample-Swift/AdjustExample-Swift/Adjust/

# Copy static framework into example WebView app
rm -rf examples/AdjustExample-WebView/AdjustExample-WebView/Adjust/AdjustSdk.framework
cp -R Frameworks/Static/AdjustSdk.framework examples/AdjustExample-WebView/AdjustExample-WebView/Adjust/

# Copy static framework into example iWatch app
rm -rf examples/AdjustExample-iWatch/AdjustExample-iWatch/Adjust/AdjustSdk.framework
cp -R Frameworks/Static/AdjustSdk.framework examples/AdjustExample-iWatch/AdjustExample-iWatch/Adjust/

# Copy static framework into example tvOS app
rm -rf examples/AdjustExample-tvOS/AdjustExample-tvOS/Adjust/AdjustSdk.framework
cp -R Frameworks/Static/AdjustSdk.framework examples/AdjustExample-tvOS/AdjustExample-tvOS/Adjust/

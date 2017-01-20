#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Go to root folder
cd ..

# Clean the folders
rm -rf Frameworks/Static
rm -rf Frameworks/Dynamic
rm -rf Frameworks/tvOS
rm -rf Frameworks/IM

# Create needed folders
mkdir -p Frameworks/Static
mkdir -p Frameworks/Dynamic
mkdir -p Frameworks/tvOS
mkdir -p Frameworks/IM

# Build static AdjustSdk.framework
xcodebuild -target AdjustStatic -configuration Release clean build

# Build dynamic AdjustSdk.framework
xcodebuild -target AdjustSdk -configuration Release clean build

# Build tvOS AdjustSdkTV.framework
# Build it for simulator and device
xcodebuild -configuration Release -target AdjustSdkTv -arch x86_64 -sdk appletvsimulator clean build
xcodebuild -configuration Release -target AdjustSdkTv -arch arm64 -sdk appletvos clean build

# Build iMessage AdjustSdkIM.framework
xcodebuild -target AdjustSdkIM -configuration Release clean build

# Copy tvOS framework to destination
cp -R build/Release-appletvos/AdjustSdkTv.framework Frameworks/tvOS

# Create universal tvOS framework
lipo -create -output Frameworks/tvOS/AdjustSdkTv.framework/AdjustSdkTv build/Release-appletvos/AdjustSdkTv.framework/AdjustSdkTv build/Release-appletvsimulator/AdjustSdkTv.framework/AdjustSdkTv

# Build Carthage AdjustSdk.framework
carthage build --no-skip-current

# Copy build Carthage Dynamic framework to Dynamic Frameworks folder
cp -R Carthage/Build/iOS/243EF3FD-B9EB-374A-8459-41EE5143E88E.bcsymbolmap \
Carthage/Build/iOS/B8B02FD6-0AC8-3BD6-BF5F-D2B94CF03DB3.bcsymbolmap \
Carthage/Build/iOS/AdjustSdk.framework \
Carthage/Build/iOS/AdjustSdk.framework.dSYM Frameworks/Dynamic/

# Copy build Carthage IM framework to Dynamic Frameworks folder
cp -R Carthage/Build/iOS/13E00C69-807D-3274-9D45-263BD4829C18.bcsymbolmap \
Carthage/Build/iOS/22783FF9-BEA8-3055-BE3D-55E3AC9F8A0D.bcsymbolmap \
Carthage/Build/iOS/AdjustSdkIM.framework \
Carthage/Build/iOS/AdjustSdkIM.framework.dSYM Frameworks/IM/

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
rm -rf examples/AdjustExample-tvOS/AdjustExample-tvOS/Adjust/AdjustSdkTv.framework
cp -R Frameworks/tvOS/AdjustSdkTv.framework examples/AdjustExample-tvOS/AdjustExample-tvOS/Adjust/

# Copy iMessage framework into example IM app
rm -rf examples/AdjustExample-iMessageExtension/AdjustExample-iMessageExtension/Adjust/AdjustSdkIM.framework
cp -R Frameworks/IM/AdjustSdkIM.framework examples/AdjustExample-iMessageExtension/AdjustExample-iMessageExtension/Adjust/AdjustSdkIM.framework

#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Go to root folder
cd ..

# Create needed folders if they don't exist
mkdir -p Frameworks/Static
mkdir -p Frameworks/Dynamic
mkdir -p Frameworks/Carthage

# Build static AdjustSdk.framework
xcodebuild -target AdjustStatic -configuration Release

# Build dynamic AdjustSdk.framework
xcodebuild -target AdjustSdk -configuration Release

# Build Carthage AdjustSdk.framework
carthage build --no-skip-current

# Copy build Carthage framework to Frameworks folder
cp -R Carthage/Build/iOS/* Frameworks/Carthage/

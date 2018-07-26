#!/usr/bin/env bash

set -e

# ======================================== #

# Colors for output
NC='\033[0m'
RED='\033[0;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'

# ======================================== #

# Directories and paths of interest for the script.
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"
cd ${ROOT_DIR}

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Removing framework targets folders ... ${NC}"
rm -rf ${ROOT_DIR}/frameworks/static
rm -rf ${ROOT_DIR}/frameworks/dynamic
rm -rf ${ROOT_DIR}/frameworks/tvos
rm -rf ${ROOT_DIR}/frameworks/imessage
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Creating framework targets folders ... ${NC}"
mkdir -p ${ROOT_DIR}/frameworks/static
mkdir -p ${ROOT_DIR}/frameworks/dynamic
mkdir -p ${ROOT_DIR}/frameworks/tvos
mkdir -p ${ROOT_DIR}/frameworks/imessage
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Bulding static SDK framework and copying it to destination folder ... ${NC}"
xcodebuild -target AdjustStatic -configuration Release clean build
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Bulding universal tvOS SDK framework (device + simulator) and copying it to destination folder ... ${NC}"
xcodebuild -configuration Release -target AdjustSdkTv -arch x86_64 -sdk appletvsimulator clean build
xcodebuild -configuration Release -target AdjustSdkTv -arch arm64 -sdk appletvos clean build
cp -Rv build/Release-appletvos/AdjustSdkTv.framework frameworks/tvos
lipo -create -output frameworks/tvos/AdjustSdkTv.framework/AdjustSdkTv build/Release-appletvos/AdjustSdkTv.framework/AdjustSdkTv build/Release-appletvsimulator/AdjustSdkTv.framework/AdjustSdkTv
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Bulding shared dynamic targets with Carthage ... ${NC}"
carthage build --no-skip-current
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Copying Carthage generated dynamic SDK framework to destination folder ... ${NC}"
cp -Rv Carthage/Build/iOS/* frameworks/dynamic/
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Bulding static test library framework and copying it to destination folder ... ${NC}"
cd ${ROOT_DIR}/AdjustTests/AdjustTestLibrary
xcodebuild -target AdjustTestLibraryStatic -configuration Debug clean build
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Script completed! ${NC}"

#!/usr/bin/env bash
#
# IMPORTANT:
#
# => This script should be called from the [SOURCE_ROOT]/ folder, i.e. "ios_sdk_dev/".
#
# => The output results can be found in [SOURCE_ROOT]/sdk_distribution, i.e. "ios_sdk_dev/sdk_distribution"
#
# => EXAMPLES:
#
# 1. To build all variants, run the following:
# ./scripts/build_frameworks.sh -all
#
# The following command has the same result as "-all" flag usage:
# ./scripts/build_frameworks.sh -fs -fd -xs -xd -ios -tv -im -web
#
# 2. To build static frameworks and xcframeworks for iOS and tvOS only:
# ./scripts/build_frameworks.sh -fs -xs -ios -tv
#


set -e

# ======================================== #

# Colors for output
NC='\033[0m'
RED='\033[0;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Executing definitions script... ${NC}"
source ./scripts/build_definitions.sh "$@"
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Executing definitions script - Done! ${NC}"

# ======================================== #

if [[ $BUILD_DYNAMIC_FRAMEWORK -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Dynamic Frameworks... ${NC}"
  source ./scripts/dynamic_frameworks.sh
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Dynamic Frameworks - Done! ${NC}"
fi
# ======================================== #

if [[ $BUILD_STATIC_FRAMEWORK -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Static Frameworks... ${NC}"
  source ./scripts/static_frameworks.sh
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Static Frameworks - Done! ${NC}"
fi

# ======================================== #

if [[ $BUILD_DYNAMIC_XCFRAMEWORK -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Dynamic XCFrameworks... ${NC}"
  source ./scripts/dynamic_xcframeworks.sh
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Dynamic XCFrameworks - Done! ${NC}"
fi

# ======================================== #

if [[ $BUILD_STATIC_XCFRAMEWORK -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Static XCFrameworks... ${NC}"
  source ./scripts/static_xcframeworks.sh
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Static XCFrameworks - Done! ${NC}"
fi

# ======================================== #

if [[ $BUILD_TEST_FRAMEWORK -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Test Framework... ${NC}"
  source ./scripts/build_test_framework.sh
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building Test Framework - Done! ${NC}"
fi


# ======================================== #



#!/usr/bin/env bash

# ======================================== #

if [[ $BUILD_TEST_FRAMEWORK -eq 1 ]] || [[ $BUILD_TEST_FRAMEWORK_SIM -eq 1 ]]
then
	if [[ $BUILD_TEST_FRAMEWORK -eq 1 ]]
	then
		echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building static test library framework for Device and copying it to destination folder ... ${NC}"
		cd "AdjustTests/AdjustTestLibrary"
		xcodebuild -target AdjustTestLibraryStatic -configuration Debug clean build
		cd -
		echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"
	fi

	if [[ $BUILD_TEST_FRAMEWORK_SIM -eq 1 ]]
	then
		echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building static test library framework for Simulator and copying it to destination folder ... ${NC}"
		cd "AdjustTests/AdjustTestLibrary"
		xcodebuild -target AdjustTestLibraryStaticSimulatorOnly -configuration Debug clean build
		cd -
		echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"
	fi
fi

# ======================================== #


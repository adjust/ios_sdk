#!/usr/bin/env bash

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building static test library framework and copying it to destination folder ... ${NC}"
cd "AdjustTests/AdjustTestLibrary"
xcodebuild -target AdjustTestLibraryStatic -configuration Debug clean build
cd -
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #


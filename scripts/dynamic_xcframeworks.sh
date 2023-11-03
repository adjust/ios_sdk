#!/usr/bin/env bash

source ./scripts/build_definitions.sh -xd

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic XCFrameworks build - START... ${NC}"

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_IOS -eq 1 ]] || [[ $BUILD_TARGET_TVOS -eq 1 ]]
then  

  TRAGET_PLATFORM_DESCRIPTION=""
  if [[ $BUILD_TARGET_IOS -eq 1 ]] && [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then  
    TRAGET_PLATFORM_DESCRIPTION="iOS and tvOS"
  elif [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    TRAGET_PLATFORM_DESCRIPTION="iOS"
  elif [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    TRAGET_PLATFORM_DESCRIPTION="tvOS"
  fi

    echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
    echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Xcode archives for ${TRAGET_PLATFORM_DESCRIPTION} ...${NC}"
    echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  if [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    build_archive "${SCHEMA_NAME__ADJUST_IOS}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}"
    build_archive "${SCHEMA_NAME__ADJUST_IOS}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}"
    IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__IOS_DEVICE}" "${XCF_OUTPUT_FOLDER}")
  fi

  if [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    build_archive "${SCHEMA_NAME__ADJUST_TV}" "appletvos" "generic/platform=tvOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}"
    build_archive "${SCHEMA_NAME__ADJUST_TV}" "appletvsimulator" "generic/platform=tvOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}"
    TV_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__TV_DEVICE}" "${XCF_OUTPUT_FOLDER}")
  fi

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Creating Dynamic XCFramework for ${TRAGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  if [[ $BUILD_TARGET_IOS -eq 1 ]] && [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then  
    if [[ $XCODE12PLUS > 0 ]]; then
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IOS}.framework.dSYM" \
        ${IOS_BCSYMBOLS} \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IOS}.framework.dSYM" \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_TV}.framework.dSYM" \
        ${TV_BCSYMBOLS} \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_TV}.framework.dSYM" \
        -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    else
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    fi
  elif [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    if [[ $XCODE12PLUS > 0 ]]; then
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IOS}.framework.dSYM" \
        ${IOS_BCSYMBOLS} \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IOS}.framework.dSYM" \
        -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    else
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    fi
  elif [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    if [[ $XCODE12PLUS > 0 ]]; then
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_TV}.framework.dSYM" \
        ${TV_BCSYMBOLS} \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_TV}.framework.dSYM" \
        -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_TV}.xcframework"
    else
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_TV}.xcframework"
    fi
  fi

  # Cleanup archive files
  if [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive"
    rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive"
  fi

  if [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive"
    rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive"
  fi

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Archiving (ZIP) Dynamic XCFramework for ${TRAGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  # VERIFY

  if [[ $BUILD_TARGET_IOS -eq 1 ]] && [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IOS}.xcframework" "${XCF_FRM_ZIP_NAME__IOS_TV_DYNAMIC}-"${SDK_VERSION}".xcframework.zip"
  elif [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IOS}.xcframework" "${XCF_FRM_ZIP_NAME__IOS_DYNAMIC}-"${SDK_VERSION}".xcframework.zip"
  else
    archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_TV}.xcframework" "${XCF_FRM_ZIP_NAME__TV_DYNAMIC}-"${SDK_VERSION}".xcframework.zip"
  fi

fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_IM -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Xcode archives for iOS (iMessage) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="${NC}
  build_archive "${SCHEMA_NAME__ADJUST_IM}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}"
  build_archive "${SCHEMA_NAME__ADJUST_IM}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}"

  IM_IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__IM_DEVICE}" "${XCF_OUTPUT_FOLDER}")

  # Create XCFramework
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Creating Dynamic XCFramework for iOS (iMessage) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  if [[ $XCODE12PLUS > 0 ]]; then
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IM}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IM}.framework.dSYM" \
    ${IM_IOS_BCSYMBOLS} \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IM}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IM}.framework.dSYM" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IM}.xcframework"
  else
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IM}.framework" \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IM}.framework" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IM}.xcframework"
  fi

  # Cleanup archive files
  rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive"
  rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Archiving (ZIP) Dynamic XCFramework for iOS (iMessage) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IM}.xcframework" "${XCF_FRM_ZIP_NAME__IM_DYNAMIC}-"${SDK_VERSION}".xcframework.zip"
fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Xcode archives for iOS (WebBridge) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_archive "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}"
  build_archive "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}"

  WEB_IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__WEB_DEVICE}" "${XCF_OUTPUT_FOLDER}")

  # Create XCFramework
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Creating Dynamic XCFramework for iOS (WebBridge) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  if [[ $XCODE12PLUS > 0 ]]; then

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework.dSYM" \
    ${WEB_IOS_BCSYMBOLS} \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework.dSYM" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework"

  else

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework"

  fi

  # Cleanup archive files
  rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive"
  rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Archiving (ZIP) Dynamic XCFramework for iOS (WebBridge) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework" "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC}-"${SDK_VERSION}".xcframework.zip"
fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic XCFrameworks build - END... ${NC}"

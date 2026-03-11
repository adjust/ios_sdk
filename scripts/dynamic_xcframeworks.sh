#!/usr/bin/env bash

source ./scripts/build_definitions.sh -xd

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic XCFrameworks build - START... ${NC}"

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

ARCHIVE_LOCATION_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMKS_FOLDER}"

if [[ $BUILD_TARGET_IOS -eq 1 ]] || [[ $BUILD_TARGET_TVOS -eq 1 ]]
then

  TARGET_PLATFORM_DESCRIPTION=""
  if [[ $BUILD_TARGET_IOS -eq 1 ]] && [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    TARGET_PLATFORM_DESCRIPTION="iOS and tvOS"
  elif [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    TARGET_PLATFORM_DESCRIPTION="iOS"
  elif [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    TARGET_PLATFORM_DESCRIPTION="tvOS"
  fi

    echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
    echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Xcode archives for ${TARGET_PLATFORM_DESCRIPTION} ...${NC}"
    echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  if [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    build_archive "${SCHEMA_NAME__ADJUST_IOS}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}"
    build_archive "${SCHEMA_NAME__ADJUST_IOS}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}"
    IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__IOS_DEVICE}" "${XCF_OUTPUT_ROOT_FOLDER}")
  fi

  if [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    build_archive "${SCHEMA_NAME__ADJUST_TV}" "appletvos" "generic/platform=tvOS" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}"
    build_archive "${SCHEMA_NAME__ADJUST_TV}" "appletvsimulator" "generic/platform=tvOS Simulator" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}"
    TV_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__TV_DEVICE}" "${XCF_OUTPUT_ROOT_FOLDER}")
  fi

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Creating Dynamic XCFramework for ${TARGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"


  ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER=""
  ARCHIVE_NAME=""
  XCFRAMEWORK_OUTPUT_PATH=""

  if [[ $BUILD_TARGET_IOS -eq 1 ]] && [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then

    ARCHIVE_NAME="${XCF_OUTPUT_FRMK_IOS_TV_FOLDER_DYNAMIC}-${SDK_VERSION}.xcframework.zip"
    ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_IOS_TV_FOLDER_DYNAMIC}-xcframework/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

    if [[ $XCODE12PLUS > 0 ]]; then
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IOS}.framework.dSYM" \
        ${IOS_BCSYMBOLS} \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IOS}.framework.dSYM" \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_TV}.framework.dSYM" \
        ${TV_BCSYMBOLS} \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_TV}.framework.dSYM" \
        -output "${XCFRAMEWORK_OUTPUT_PATH}"
    else
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -output "${XCFRAMEWORK_OUTPUT_PATH}"
    fi

  elif [[ $BUILD_TARGET_IOS -eq 1 ]]
  then

    ARCHIVE_NAME="${XCF_OUTPUT_FRMK_IOS_FOLDER_DYNAMIC}-${SDK_VERSION}.xcframework.zip"
    ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_IOS_FOLDER_DYNAMIC}-xcframework/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

    if [[ $XCODE12PLUS > 0 ]]; then
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IOS}.framework.dSYM" \
        ${IOS_BCSYMBOLS} \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IOS}.framework.dSYM" \
        -output "${XCFRAMEWORK_OUTPUT_PATH}"
    else
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
        -output "${XCFRAMEWORK_OUTPUT_PATH}"
    fi
  elif [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then

    ARCHIVE_NAME="${XCF_OUTPUT_FRMK_TV_FOLDER_DYNAMIC}-${SDK_VERSION}.xcframework.zip"
    ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_TV_FOLDER_DYNAMIC}-xcframework/${XCF_FRM_NAME__ADJUST_TV}.xcframework"
    XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

    if [[ $XCODE12PLUS > 0 ]]; then
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_TV}.framework.dSYM" \
        ${TV_BCSYMBOLS} \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_TV}.framework.dSYM" \
        -output "${XCFRAMEWORK_OUTPUT_PATH}"
    else
        xcodebuild -create-xcframework \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_TV}.framework" \
        -output "${XCFRAMEWORK_OUTPUT_PATH}"
    fi
  fi

  # Cleanup archive files
  if [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive"
    rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive"
  fi

  if [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive"
    rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive"
  fi

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Dynamic XCFramework for ${TARGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  # VERIFY

  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "${XCFRAMEWORK_OUTPUT_PATH}"
  archive_framework "${ARCHIVE_LOCATION_FOLDER}" "${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}" "${ARCHIVE_NAME}"

fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_IM -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Xcode archives for iOS (iMessage) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="${NC}
  build_archive "${SCHEMA_NAME__ADJUST_IM}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}"
  build_archive "${SCHEMA_NAME__ADJUST_IM}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}"

  IM_IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__IM_DEVICE}" "${XCF_OUTPUT_ROOT_FOLDER}")

  # Create XCFramework
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Creating Dynamic XCFramework for iOS (iMessage) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  ARCHIVE_NAME="${XCF_OUTPUT_FRMK_IM_FOLDER_DYNAMIC}-${SDK_VERSION}.xcframework.zip"
  ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_IM_FOLDER_DYNAMIC}-xcframework/${XCF_FRM_NAME__ADJUST_IM}.xcframework"
  XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

  if [[ $XCODE12PLUS > 0 ]]; then
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IM}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IM}.framework.dSYM" \
    ${IM_IOS_BCSYMBOLS} \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IM}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_IM}.framework.dSYM" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"
  else
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IM}.framework" \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_IM}.framework" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"
  fi

  # Cleanup archive files
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive"
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Dynamic XCFramework for iOS (iMessage) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  
  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "${XCFRAMEWORK_OUTPUT_PATH}"
  archive_framework "${ARCHIVE_LOCATION_FOLDER}" "${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}" "${ARCHIVE_NAME}"

fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Xcode archives for iOS (WebBridge) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_archive "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}"
  build_archive "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}"

  WEB_IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__WEB_DEVICE}" "${XCF_OUTPUT_ROOT_FOLDER}")

  # Create XCFramework
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Creating Dynamic XCFramework for iOS (WebBridge) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  ARCHIVE_NAME="${XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_DYNAMIC}-${SDK_VERSION}.xcframework.zip"
  ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_DYNAMIC}-xcframework/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework"
  XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

  if [[ $XCODE12PLUS > 0 ]]; then

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework.dSYM" \
    ${WEB_IOS_BCSYMBOLS} \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework.dSYM" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"

  else

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"

  fi

  # Cleanup archive files
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive"
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Dynamic XCFramework for iOS (WebBridge) ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  
  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "${XCFRAMEWORK_OUTPUT_PATH}"
  archive_framework "${ARCHIVE_LOCATION_FOLDER}" "${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}" "${ARCHIVE_NAME}"

fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_ODM_FRAMEWORK -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Xcode archives for ODM Plugin ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_archive "${SCHEMA_NAME__ODM_DYNAMIC}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_DEVICE}"
  build_archive "${SCHEMA_NAME__ODM_DYNAMIC}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_SIMULATOR}"

  ODM_IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__ODM_DEVICE}" "${XCF_OUTPUT_ROOT_FOLDER}")

  # Create XCFramework
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Creating Dynamic XCFramework for ODM Plugin ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  ARCHIVE_NAME="${XCF_OUTPUT_FRMK_ODM_FOLDER_DYNAMIC}-${SDK_VERSION}.xcframework.zip"
  ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_ODM_FOLDER_DYNAMIC}-xcframework/${XCF_FRM_NAME__ADJUST_ODM}.xcframework"
  XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"


  if [[ $XCODE12PLUS > 0 ]]; then
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_ODM}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_DEVICE}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_ODM}.framework.dSYM" \
    ${ODM_IOS_BCSYMBOLS} \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_ODM}.framework" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_SIMULATOR}.xcarchive/dSYMs/${XCF_FRM_NAME__ADJUST_ODM}.framework.dSYM" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"
  else
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_DEVICE}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_ODM}.framework" \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_SIMULATOR}.xcarchive/Products/Library/Frameworks/${XCF_FRM_NAME__ADJUST_ODM}.framework" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"
  fi

  # Cleanup archive files
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_DEVICE}.xcarchive"
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${ARCHIVE_NAME__ODM_SIMULATOR}.xcarchive"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Dynamic XCFramework for ODM Plugin ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "${XCFRAMEWORK_OUTPUT_PATH}"
  archive_framework "${ARCHIVE_LOCATION_FOLDER}" "${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}" "${ARCHIVE_NAME}"

fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic XCFrameworks build - END... ${NC}"

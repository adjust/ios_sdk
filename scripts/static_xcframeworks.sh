#!/usr/bin/env bash

source ./scripts/build_definitions.sh -xs

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Static XCFrameworks build - START... ${NC}"

ARCHIVE_LOCATION_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMKS_FOLDER}"

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
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Static XCFramework for ${TARGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  xcodebuild clean

  if [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    xcodebuild -configuration Release \
    -target "${SCHEMA_NAME__ADJUST_IOS_STATIC}" \
    -sdk iphonesimulator \
    build

    xcodebuild -configuration Release \
    -target "${SCHEMA_NAME__ADJUST_IOS_STATIC}" \
    -sdk iphoneos \
    build
  fi


  if [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    xcodebuild -configuration Release \
    -target "${SCHEMA_NAME__ADJUST_TV_STATIC}" \
    -sdk appletvsimulator \
    build

    xcodebuild -configuration Release \
    -target "${SCHEMA_NAME__ADJUST_TV_STATIC}" \
    -sdk appletvos \
    build

  fi

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Static XCFramework for ${TARGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER=""
  ARCHIVE_NAME=""
  XCFRAMEWORK_OUTPUT_PATH=""

  if [[ $BUILD_TARGET_IOS -eq 1 ]] && [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then

    ARCHIVE_NAME="${XCF_OUTPUT_FRMK_IOS_TV_FOLDER_STATIC}-${SDK_VERSION}.xcframework.zip"
    ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_IOS_TV_FOLDER_STATIC}-xcframework/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvos/${XCF_FRM_NAME__ADJUST_TV}.framework" \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvsimulator/${XCF_FRM_NAME__ADJUST_TV}.framework" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"

    # Cleanup built frameworks
    rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}"
    rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}"
  elif [[ $BUILD_TARGET_IOS -eq 1 ]]
  then

    ARCHIVE_NAME="${XCF_OUTPUT_FRMK_IOS_FOLDER_STATIC}-${SDK_VERSION}.xcframework.zip"
    ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_IOS_FOLDER_STATIC}-xcframework/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"

    # Cleanup built frameworks
    rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}"
  elif [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then

    ARCHIVE_NAME="${XCF_OUTPUT_FRMK_TV_FOLDER_STATIC}-${SDK_VERSION}.xcframework.zip"
    ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_TV_FOLDER_STATIC}-xcframework/${XCF_FRM_NAME__ADJUST_TV}.xcframework"
    XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvos/${XCF_FRM_NAME__ADJUST_TV}.framework" \
    -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvsimulator/${XCF_FRM_NAME__ADJUST_TV}.framework" \
    -output "${XCFRAMEWORK_OUTPUT_PATH}"

    # Cleanup built frameworks
    rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}"
  fi

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Static XCFramework for ${TARGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "${XCFRAMEWORK_OUTPUT_PATH}"
  archive_framework "${ARCHIVE_LOCATION_FOLDER}" "${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}" "${ARCHIVE_NAME}"

fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_IM -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Static XCFramework for iOS (iMessage)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  ARCHIVE_NAME="${XCF_OUTPUT_FRMK_IM_FOLDER_STATIC}-${SDK_VERSION}.xcframework.zip"
  ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_IM_FOLDER_STATIC}-xcframework/${XCF_FRM_NAME__ADJUST_IM}.xcframework"
  XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

  xcodebuild clean

  xcodebuild -configuration Release \
  -target ${SCHEMA_NAME__ADJUST_IM_STATIC} \
  -sdk iphonesimulator \
  build

  xcodebuild -configuration Release \
  -target ${SCHEMA_NAME__ADJUST_IM_STATIC} \
  -sdk iphoneos \
  build

  xcodebuild -create-xcframework \
  -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IM_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_IM}.framework" \
  -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IM_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_IM}.framework" \
  -output "${XCFRAMEWORK_OUTPUT_PATH}"

  # Cleanup built frameworks
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_IM_STATIC}"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Static XCFramework for iOS (iMessage)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "${XCFRAMEWORK_OUTPUT_PATH}"
  archive_framework "${ARCHIVE_LOCATION_FOLDER}" "${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}" "${ARCHIVE_NAME}"

fi


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Static XCFramework for iOS (WebBridge)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  ARCHIVE_NAME="${XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_STATIC}-${SDK_VERSION}.xcframework.zip"
  ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_STATIC}-xcframework/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework"
  XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

  xcodebuild clean

  xcodebuild -configuration Release \
  -target ${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC} \
  -sdk iphonesimulator \
  build

  xcodebuild -configuration Release \
  -target ${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC} \
  -sdk iphoneos \
  build

  xcodebuild -create-xcframework \
  -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
  -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
  -output "${XCFRAMEWORK_OUTPUT_PATH}"

  # Cleanup built frameworks
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Static XCFramework for iOS (WebBridge)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  
  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "${XCFRAMEWORK_OUTPUT_PATH}"
  archive_framework "${ARCHIVE_LOCATION_FOLDER}" "${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}" "${ARCHIVE_NAME}"

fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_ODM_FRAMEWORK -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Static XCFramework for ODM Plugin...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  ARCHIVE_NAME="${XCF_OUTPUT_FRMK_ODM_FOLDER_STATIC}-${SDK_VERSION}.xcframework.zip"
  ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER="${XCF_OUTPUT_FRMK_ODM_FOLDER_STATIC}-xcframework/${XCF_FRM_NAME__ADJUST_ODM}.xcframework"
  XCFRAMEWORK_OUTPUT_PATH="./${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMKS_FOLDER}/${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}"

  xcodebuild clean

  xcodebuild -configuration Release \
  -target ${SCHEMA_NAME__ODM_STATIC} \
  -sdk iphonesimulator \
  build

  xcodebuild -configuration Release \
  -target ${SCHEMA_NAME__ODM_STATIC} \
  -sdk iphoneos \
  build

  xcodebuild -create-xcframework \
  -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ODM_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_ODM}.framework" \
  -framework "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ODM_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_ODM}.framework" \
  -output "${XCFRAMEWORK_OUTPUT_PATH}"

  # Cleanup built frameworks
  rm -rf "./${XCF_OUTPUT_ROOT_FOLDER}/${SCHEMA_NAME__ODM_STATIC}"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Static XCFramework for ODM Plugin...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  
  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "${XCFRAMEWORK_OUTPUT_PATH}"
  archive_framework "${ARCHIVE_LOCATION_FOLDER}" "${ARCHIVE_FRAMEWORK_PATH_WITH_PARENT_FOLDER}" "${ARCHIVE_NAME}"

fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Static XCFrameworks build - END... ${NC}"

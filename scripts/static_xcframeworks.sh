#!/usr/bin/env bash

source ./scripts/build_definitions.sh -xs

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Static XCFrameworks build - START... ${NC}"

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
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Buiding Static XCFramework for ${TRAGET_PLATFORM_DESCRIPTION} ...${NC}"
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
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Buiding Static XCFramework for ${TRAGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  if [[ $BUILD_TARGET_IOS -eq 1 ]] && [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
    -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
    -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvos/${XCF_FRM_NAME__ADJUST_TV}.framework" \
    -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvsimulator/${XCF_FRM_NAME__ADJUST_TV}.framework" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"

    # Cleanup built frameworks
    rm -rf "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}"
    rm -rf "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}"
  elif [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
    -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"

    # Cleanup built frameworks
    rm -rf "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}"
  elif [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvos/${XCF_FRM_NAME__ADJUST_TV}.framework" \
    -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvsimulator/${XCF_FRM_NAME__ADJUST_TV}.framework" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_TV}.xcframework"

    # Cleanup built frameworks
    rm -rf "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}"
  fi

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Static XCFramework for ${TRAGET_PLATFORM_DESCRIPTION} ...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

  if [[ $BUILD_TARGET_IOS -eq 1 ]] && [[ $BUILD_TARGET_TVOS -eq 1 ]]
  then
    codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IOS}.xcframework" "${XCF_FRM_ZIP_NAME__IOS_TV_STATIC}-"${SDK_VERSION}".xcframework.zip"
  elif [[ $BUILD_TARGET_IOS -eq 1 ]]
  then
    codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"
    archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IOS}.xcframework" "${XCF_FRM_ZIP_NAME__IOS_STATIC}-"${SDK_VERSION}".xcframework.zip"
  else
    codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_TV}.xcframework"
    archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_TV}.xcframework" "${XCF_FRM_ZIP_NAME__TV_STATIC}-"${SDK_VERSION}".xcframework.zip"
  fi
fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_IM -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Buiding Static XCFramework for iOS (iMessage)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

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
  -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IM_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_IM}.framework" \
  -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IM_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_IM}.framework" \
  -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IM}.xcframework"

  # Cleanup built frameworks
  rm -rf "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IM_STATIC}"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Static XCFramework for iOS (iMessage)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IM}.xcframework"
  archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IM}.xcframework" "${XCF_FRM_ZIP_NAME__IM_STATIC}-"${SDK_VERSION}".xcframework.zip"
fi


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Buiding Static XCFramework for iOS (WebBridge)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"

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
  -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
  -framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.framework" \
  -output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework"

  # Cleanup built frameworks
  rm -rf "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}"

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Signing and Archiving (ZIP) Static XCFramework for iOS (WebBridge)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  codesign -s "$SDK_CODE_SIGN_IDENTITY" -f --timestamp "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework"
  archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework" "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_STATIC}-"${SDK_VERSION}".xcframework.zip"
fi

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Static XCFrameworks build - END... ${NC}"

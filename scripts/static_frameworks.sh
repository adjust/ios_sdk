#!/usr/bin/env bash

source ./scripts/build_definitions.sh -fs

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Static Frameworks build - START... ${NC}"

mkdir -p "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}"

if [[ $BUILD_TARGET_IOS -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Buiding Static Frameworks for iOS...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ADJUST_IOS_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_IOS}" "${XCF_OUTPUT_FOLDER}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}" "${XCF_FRM_ZIP_NAME__IOS_STATIC}-"${SDK_VERSION}".framework.zip"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iOS SDK framework build ... ${NC}"
fi

if [[ $BUILD_TARGET_TVOS -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Buiding static Frameworks for tvOS...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ADJUST_TV_STATIC}" "tvos" "${XCF_FRM_NAME__ADJUST_TV}" "${XCF_OUTPUT_FOLDER}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}" "${XCF_FRM_ZIP_NAME__TV_STATIC}-"${SDK_VERSION}".framework.zip"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping tvOS SDK framework build ... ${NC}"
fi

if [[ $BUILD_TARGET_IM -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Buiding static Frameworks for iOS (iMessage)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ADJUST_IM_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_IM}" "${XCF_OUTPUT_FOLDER}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}" "${XCF_FRM_ZIP_NAME__IM_STATIC}-"${SDK_VERSION}".framework.zip"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iMessage SDK framework build ... ${NC}"
fi

if [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Buiding static Frameworks for iOS (WebBridge)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}" "${XCF_OUTPUT_FOLDER}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}" "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_STATIC}-"${SDK_VERSION}".framework.zip"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iOS (WebBridge) SDK framework build ... ${NC}"
fi


echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Static Frameworks build - END... ${NC}"


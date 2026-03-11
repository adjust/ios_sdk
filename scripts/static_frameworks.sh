#!/usr/bin/env bash

source ./scripts/build_definitions.sh -fs

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Static Frameworks build - START... ${NC}"

if [[ $BUILD_TARGET_IOS -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_IOS_FOLDER_STATIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_IOS_FOLDER_STATIC}-${SDK_VERSION}.framework.zip"

  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Static Frameworks for iOS...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ADJUST_IOS_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_IOS}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iOS SDK framework build ... ${NC}"
fi

if [[ $BUILD_TARGET_TVOS -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_TV_FOLDER_STATIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_TV_FOLDER_STATIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building static Frameworks for tvOS...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ADJUST_TV_STATIC}" "tvos" "${XCF_FRM_NAME__ADJUST_TV}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping tvOS SDK framework build ... ${NC}"
fi

if [[ $BUILD_TARGET_IM -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_IM_FOLDER_STATIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_IM_FOLDER_STATIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building static Frameworks for iOS (iMessage)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ADJUST_IM_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_IM}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iMessage SDK framework build ... ${NC}"
fi

if [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_STATIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_STATIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building static Frameworks for iOS (WebBridge)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iOS (WebBridge) SDK framework build ... ${NC}"
fi

if [[ $BUILD_TARGET_ODM_FRAMEWORK -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_STATIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_ODM_FOLDER_STATIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_ODM_FOLDER_STATIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building static Frameworks for ODM Plugin...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_static_fat_framework "${SCHEMA_NAME__ODM_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_ODM}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping ODM plugin framework build ... ${NC}"
fi

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Static Frameworks build - END... ${NC}"

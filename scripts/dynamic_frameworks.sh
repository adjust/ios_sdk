#!/usr/bin/env bash

source ./scripts/build_definitions.sh -fd

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic Frameworks build - START... ${NC}"

# ======================================== #

if [[ $BUILD_TARGET_IOS -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_IOS_FOLDER_DYNAMIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_IOS_FOLDER_DYNAMIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Dynamic Frameworks for iOS...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_dynamic_fat_framework "${SCHEMA_NAME__ADJUST_IOS}" "ios" "${XCF_FRM_NAME__ADJUST_IOS}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iOS SDK Dynamic Framework build ... ${NC}"
fi


# ======================================== #

if [[ $BUILD_TARGET_TVOS -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_TV_FOLDER_DYNAMIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_TV_FOLDER_DYNAMIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Dynamic Frameworks for tvOS...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_dynamic_fat_framework "${SCHEMA_NAME__ADJUST_TV}" "tvos" "${XCF_FRM_NAME__ADJUST_TV}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping tvOS SDK Dynamic Framework build ... ${NC}"
fi

# ======================================== #

if [[ $BUILD_TARGET_IM -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_IM_FOLDER_DYNAMIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_IM_FOLDER_DYNAMIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Dynamic Frameworks for iOS (iMessage)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_dynamic_fat_framework "${SCHEMA_NAME__ADJUST_IM}" "ios" "${XCF_FRM_NAME__ADJUST_IM}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iOS (iMessage) SDK Dynamic Framework build ... ${NC}"
fi

# ======================================== #

if [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_DYNAMIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_DYNAMIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Dynamic Frameworks for iOS (WebBridge)...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_dynamic_fat_framework "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "ios" "${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iOS (WebBridge) SDK Dynamic Framework build ... ${NC}"
fi


# ======================================== #

if [[ $BUILD_TARGET_ODM_FRAMEWORK -eq 1 ]]
then
  TEMP_OUTPUT_FOLDER="${XCF_OUTPUT_ROOT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMKS_FOLDER}/${XCF_OUTPUT_FRMK_ODM_FOLDER_DYNAMIC}-framework"
  ARCHIVE_FILE_NAME="${XCF_OUTPUT_FRMK_ODM_FOLDER_DYNAMIC}-${SDK_VERSION}.framework.zip"
  mkdir -p "${TEMP_OUTPUT_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} XCFramework: Building Dynamic Frameworks for ODM Plugin...${NC}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =${NC}"
  build_dynamic_fat_framework "${SCHEMA_NAME__ODM_DYNAMIC}" "ios" "${XCF_FRM_NAME__ADJUST_ODM}" "${XCF_OUTPUT_ROOT_FOLDER}" "${TEMP_OUTPUT_FOLDER}" "${ARCHIVE_FILE_NAME}"
else
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping ODM Plugin Dynamic Framework build ... ${NC}"
fi

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic Frameworks build - END... ${NC}"

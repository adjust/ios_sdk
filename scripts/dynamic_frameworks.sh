#!/usr/bin/env bash

source ./scripts/build_definitions.sh -fd

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic Frameworks build - START... ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Removing framework targets folders ... ${NC}"
rm -rf Carthage
rm -rf "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Creating framework targets folders ... ${NC}"
mkdir -p "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Moving shared schemas to generate dynamic iOS SDK framework using Carthage ... ${NC}"
mv Adjust.xcodeproj/xcshareddata/xcschemes/AdjustSdkIm.xcscheme \
   Adjust.xcodeproj/xcshareddata/xcschemes/AdjustSdkWebBridge.xcscheme \
   Adjust.xcodeproj/xcshareddata/xcschemes/AdjustSdkTv.xcscheme .
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

if [[ $BUILD_TARGET_IOS -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Bulding dynamic iOS target with Carthage ... ${NC}"
  arch -x86_64 /bin/bash ./scripts/carthage_xcode.sh build --no-skip-current
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

  # ======================================== #

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Move Carthage generated dynamic iOS SDK framework to destination folder ... ${NC}"
  cd "Carthage/Build"
  mv "iOS" "${XCF_FRM_ZIP_NAME__IOS_DYNAMIC}"
  zip -r -X "${XCF_FRM_ZIP_NAME__IOS_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_FRM_ZIP_NAME__IOS_DYNAMIC}"
  cd -
  mv "Carthage/Build/${XCF_FRM_ZIP_NAME__IOS_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  mv "Carthage/Build/${XCF_FRM_ZIP_NAME__IOS_DYNAMIC}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"
else 
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iOS SDK framework build ... ${NC}"
fi

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Moving shared schemas to generate dynamic tvOS SDK framework using Carthage ... ${NC}"
mv Adjust.xcodeproj/xcshareddata/xcschemes/AdjustSdk.xcscheme .
mv AdjustSdkTv.xcscheme Adjust.xcodeproj/xcshareddata/xcschemes
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

if [[ $BUILD_TARGET_TVOS -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Bulding dynamic tvOS targets with Carthage ... ${NC}"
  arch -x86_64 /bin/bash ./scripts/carthage_xcode.sh build --no-skip-current
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

  # ======================================== #

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Move Carthage generated dynamic tvOS SDK framework to destination folder ... ${NC}"
  cd "Carthage/Build"
  mv "tvOS" "${XCF_FRM_ZIP_NAME__TV_DYNAMIC}"
  zip -r -X "${XCF_FRM_ZIP_NAME__TV_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_FRM_ZIP_NAME__TV_DYNAMIC}"
  cd -
  mv "Carthage/Build/${XCF_FRM_ZIP_NAME__TV_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  mv "Carthage/Build/${XCF_FRM_ZIP_NAME__TV_DYNAMIC}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"
else 
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping tvOS SDK framework build ... ${NC}"
fi

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Moving shared schemas to generate dynamic iMessage SDK framework using Carthage ... ${NC}"
mv Adjust.xcodeproj/xcshareddata/xcschemes/AdjustSdkTv.xcscheme .
mv AdjustSdkIm.xcscheme Adjust.xcodeproj/xcshareddata/xcschemes
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

if [[ $BUILD_TARGET_IM -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Bulding dynamic iMessage target with Carthage ... ${NC}"
  #carthage build --no-skip-current
  arch -x86_64 /bin/bash ./scripts/carthage_xcode.sh build --no-skip-current
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

  # ======================================== #

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Move Carthage generated dynamic iMessage SDK framework to destination folder ... ${NC}"
  cd "Carthage/Build"
  mv "iOS" "${XCF_FRM_ZIP_NAME__IM_DYNAMIC}"
  zip -r -X "${XCF_FRM_ZIP_NAME__IM_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_FRM_ZIP_NAME__IM_DYNAMIC}"
  cd -
  mv "Carthage/Build/${XCF_FRM_ZIP_NAME__IM_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  mv "Carthage/Build/${XCF_FRM_ZIP_NAME__IM_DYNAMIC}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"
else 
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping iMessage SDK framework build ... ${NC}"
fi

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Moving shared schemas to generate dynamic WebBridge SDK framework using Carthage ... ${NC}"
mv Adjust.xcodeproj/xcshareddata/xcschemes/AdjustSdkIm.xcscheme .
mv AdjustSdkWebBridge.xcscheme Adjust.xcodeproj/xcshareddata/xcschemes
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

if [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Bulding dynamic WebBridge target with Carthage ... ${NC}"
  #carthage build --no-skip-current
  arch -x86_64 /bin/bash ./scripts/carthage_xcode.sh build --no-skip-current
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

  # ======================================== #

  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Move Carthage generated dynamic WebBridge SDK framework to destination folder ... ${NC}"
  cd "Carthage/Build"
  mv "iOS" "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC}"
  zip -r -X "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC}"
  cd -
  mv "Carthage/Build/${XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  mv "Carthage/Build/${XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"
else 
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping WebBridge SDK framework build ... ${NC}"
fi

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Moving shared schemas back ... ${NC}"
mv *.xcscheme Adjust.xcodeproj/xcshareddata/xcschemes
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #


echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic Frameworks build - END... ${NC}"


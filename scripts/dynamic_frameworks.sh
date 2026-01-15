#!/usr/bin/env bash

source ./scripts/build_definitions.sh -fd

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic Frameworks build - START... ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Renaming Carthage to CarthageTemp ... ${NC}"
mv Carthage CarthageTemp
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

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
   Adjust.xcodeproj/xcshareddata/xcschemes/AdjustSdkTv.xcscheme \
   Adjust.xcodeproj/xcshareddata/xcschemes/AdjustOdmPlugin.xcscheme .
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

if [[ $BUILD_TARGET_IOS -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building dynamic iOS target with Carthage ... ${NC}"
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
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building dynamic tvOS targets with Carthage ... ${NC}"
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
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building dynamic iMessage target with Carthage ... ${NC}"
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
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building dynamic WebBridge target with Carthage ... ${NC}"
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

if [[ $BUILD_ODM_FRAMEWORK -eq 1 ]] && [[ $BUILD_TARGET_IOS -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Building dynamic ODM plugin framework ... ${NC}"
  ODM_BUILD_ROOT="${XCF_OUTPUT_FOLDER}/odm_build"
  rm -rf "${ODM_BUILD_ROOT}"

  xcodebuild -configuration Release \
  -target "${SCHEMA_NAME__ODM_DYNAMIC}" \
  -sdk iphonesimulator \
  EXCLUDED_ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_DIR="${ODM_BUILD_ROOT}" \
  BUILD_ROOT="${ODM_BUILD_ROOT}" \
  OBJROOT="${ODM_BUILD_ROOT}/obj" \
  SYMROOT="${ODM_BUILD_ROOT}" \
  build

  xcodebuild -configuration Release \
  -target "${SCHEMA_NAME__ODM_DYNAMIC}" \
  -sdk iphoneos \
  BUILD_DIR="${ODM_BUILD_ROOT}" \
  BUILD_ROOT="${ODM_BUILD_ROOT}" \
  OBJROOT="${ODM_BUILD_ROOT}/obj" \
  SYMROOT="${ODM_BUILD_ROOT}" \
  build

  DEVICE_FRAMEWORK="${ODM_BUILD_ROOT}/Release-iphoneos/${XCF_FRM_NAME__ODM}.framework"
  SIM_FRAMEWORK="${ODM_BUILD_ROOT}/Release-iphonesimulator/${XCF_FRM_NAME__ODM}.framework"
  UNIVERSAL_DIR="${ODM_BUILD_ROOT}/universal"
  UNIVERSAL_FRAMEWORK="${UNIVERSAL_DIR}/${XCF_FRM_NAME__ODM}.framework"

  mkdir -p "${UNIVERSAL_DIR}"
  ditto "${DEVICE_FRAMEWORK}" "${UNIVERSAL_FRAMEWORK}"
  xcrun lipo -create \
  "${DEVICE_FRAMEWORK}/${XCF_FRM_NAME__ODM}" \
  "${SIM_FRAMEWORK}/${XCF_FRM_NAME__ODM}" \
  -output "${UNIVERSAL_FRAMEWORK}/${XCF_FRM_NAME__ODM}"

  ODM_OUTPUT_DIR="${UNIVERSAL_DIR}/${XCF_FRM_ZIP_NAME__ODM_DYNAMIC}"
  mkdir -p "${ODM_OUTPUT_DIR}"
  ditto "${UNIVERSAL_FRAMEWORK}" "${ODM_OUTPUT_DIR}/${XCF_FRM_NAME__ODM}.framework"

  cd "${UNIVERSAL_DIR}"
  zip -r -X "${XCF_FRM_ZIP_NAME__ODM_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_FRM_ZIP_NAME__ODM_DYNAMIC}"
  cd -

  mv "${UNIVERSAL_DIR}/${XCF_FRM_ZIP_NAME__ODM_DYNAMIC}-"${SDK_VERSION}".framework.zip" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  mv "${ODM_OUTPUT_DIR}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_FRMK_FOLDER}"
  rm -rf "${ODM_BUILD_ROOT}"
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"
elif [[ $BUILD_ODM_FRAMEWORK -eq 1 ]]
then
  echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Skipping ODM plugin framework build (iOS target not selected) ... ${NC}"
fi

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Moving shared schemas back ... ${NC}"
mv *.xcscheme Adjust.xcodeproj/xcshareddata/xcschemes
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Remove Carthage if exist and Renaming CarthageTemp back to Carthage ... ${NC}"
rm -rf Carthage
mv CarthageTemp Carthage
echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][BUILD]:${GREEN} Dynamic Frameworks build - END... ${NC}"

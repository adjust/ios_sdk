# Output folder for xcode archoves and resulting xcframeworks
XCF_OUTPUT_FOLDER="xcframeworks"

# xcframework names
XCF_NAME__IOS_TV="AdjustSdk.xcframework"
XCF_NAME__IM="AdjustSdkIm.xcframework"
XCF_NAME__WEB_BRIDGE="AdjustSdkWebBridge.xcframework"
XCF_NAME__IOS_STATIC="AdjustSdkStatic.xcframework"

# SDK Schemas' names
SCHEMA_NAME__ADJUST_IOS="AdjustSdk"
SCHEMA_NAME__ADJUST_TV="AdjustSdkTv"
SCHEMA_NAME__ADJUST_IM="AdjustSdkIm"
SCHEMA_NAME__ADJUST_WEB_BRIDGE="AdjustSdkWebBridge"

# SDK frameworks' names
FRAMEWORK_NAME__ADJUST_IOS="AdjustSdk.framework"
FRAMEWORK_NAME__ADJUST_TV="AdjustSdkTv.framework"
FRAMEWORK_NAME__ADJUST_IM="AdjustSdkIm.framework"
FRAMEWORK_NAME__ADJUST_WEB_BRIDGE="AdjustSdkWebBridge.framework"

# xcode archive names
ARCHIVE_NAME__IOS_DEVICE="AdjustSdk-Device"
ARCHIVE_NAME__IOS_SIMULATOR="AdjustSdk-Simulator"
ARCHIVE_NAME__TV_DEVICE="AdjustSdkTv-Device"
ARCHIVE_NAME__TV_SIMULATOR="AdjustSdkTv-Simulator"
ARCHIVE_NAME__IM_DEVICE="AdjustSdkIm-Device"
ARCHIVE_NAME__IM_SIMULATOR="AdjustSdkIm-Simulator"
ARCHIVE_NAME__WEB_DEVICE="AdjustSdkWebBridge-Device"
ARCHIVE_NAME__WEB_SIMULATOR="AdjustSdkWebBridge-Simulator"

# previous builds artefacts cleanup 
rm -rf ${XCF_OUTPUT_FOLDER}
mkdir ${XCF_OUTPUT_FOLDER}

set -o pipefail

function build_archive() {
  # Prameters:
  # 1 - scheme name
  # 2 - sdk
  # 3 - destination
  # 4 - archive path

  echo "XCFramework: Building $1 - $2 Archive..."

  xcodebuild clean archive \
  -scheme "$1" \
  -configuration Release \
  -sdk "$2" \
  -destination "$3" \
  -archivePath "$4" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  GCC_GENERATE_DEBUGGING_SYMBOLS=YES

}

function generateBCSymbolsCommand() {
  # Prameters:
  # 1 - Archive name
  # 2 - Archive location folder
  #echo "XCFramework: Generating BCSymbolMap paths command from $1 ..."

  BCSYMBOLMAP_PATHS=("$(pwd -P)"/$2/$1.xcarchive/BCSymbolMaps/*)
  BCSYMBOLMAP_COMMANDS=""
  for path in "${BCSYMBOLMAP_PATHS[@]}"; do
    BCSYMBOLMAP_COMMANDS="$BCSYMBOLMAP_COMMANDS -debug-symbols $path "
  done
  echo $BCSYMBOLMAP_COMMANDS
}


XCODE12PLUS=0 
product_version=$(xcodebuild -version)
xcode_version=( ${product_version//./ } )
xcode="${xcode_version[0]}"
major="${xcode_version[1]}"
minor="${xcode_version[2]}"
echo "${xcode}.${major}.${minor}"
if [[ $major > 11 ]]; then
  XCODE12PLUS=1
fi

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_archive "${SCHEMA_NAME__ADJUST_IOS}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}"
build_archive "${SCHEMA_NAME__ADJUST_IOS}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}"
build_archive "${SCHEMA_NAME__ADJUST_TV}" "appletvos" "generic/platform=tvOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}"
build_archive "${SCHEMA_NAME__ADJUST_TV}" "appletvsimulator" "generic/platform=tvOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}"

IOS_BCSYMBOLS=$(generateBCSymbolsCommand "${ARCHIVE_NAME__IOS_DEVICE}" "${XCF_OUTPUT_FOLDER}")
TV_BCSYMBOLS=$(generateBCSymbolsCommand "${ARCHIVE_NAME__TV_DEVICE}" "${XCF_OUTPUT_FOLDER}")

# Create XCFramework
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Creating XCFramework for AdjustSdk and AdjustSdkTv..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

if [[ $XCODE12PLUS > 0 ]]; then

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_IOS}" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/dSYMs/${FRAMEWORK_NAME__ADJUST_IOS}.dSYM" \
    ${IOS_BCSYMBOLS} \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_IOS}" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/dSYMs/${FRAMEWORK_NAME__ADJUST_IOS}.dSYM" \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_TV}" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/dSYMs/${FRAMEWORK_NAME__ADJUST_TV}.dSYM" \
    ${TV_BCSYMBOLS} \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_TV}" \
    -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/dSYMs/${FRAMEWORK_NAME__ADJUST_TV}.dSYM" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_NAME__IOS_TV}"

else

    xcodebuild -create-xcframework \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_IOS}" \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_IOS}" \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_TV}" \
    -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_TV}" \
    -output "./${XCF_OUTPUT_FOLDER}/${XCF_NAME__IOS_TV}"

fi


echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_archive "${SCHEMA_NAME__ADJUST_IM}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}"
build_archive "${SCHEMA_NAME__ADJUST_IM}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}"

IM_IOS_BCSYMBOLS=$(generateBCSymbolsCommand "${ARCHIVE_NAME__IM_DEVICE}" "${XCF_OUTPUT_FOLDER}")

# Create XCFramework
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Creating XCFramework for AdjustSdkIm..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

if [[ $XCODE12PLUS > 0 ]]; then

  xcodebuild -create-xcframework \
  -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_IM}" \
  -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/dSYMs/${FRAMEWORK_NAME__ADJUST_IM}.dSYM" \
  ${IM_IOS_BCSYMBOLS} \
  -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_IM}" \
  -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/dSYMs/${FRAMEWORK_NAME__ADJUST_IM}.dSYM" \
  -output "./${XCF_OUTPUT_FOLDER}/${XCF_NAME__IM}"

else

  xcodebuild -create-xcframework \
  -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_IM}" \
  -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_IM}" \
  -output "./${XCF_OUTPUT_FOLDER}/${XCF_NAME__IM}"

fi


echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_archive "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}"
build_archive "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}"

WEB_IOS_BCSYMBOLS=$(generateBCSymbolsCommand "${ARCHIVE_NAME__WEB_DEVICE}" "${XCF_OUTPUT_FOLDER}")

# Create XCFramework
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Creating XCFramework for AdjustSdkWebBridge..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

if [[ $XCODE12PLUS > 0 ]]; then

  xcodebuild -create-xcframework \
  -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_WEB_BRIDGE}" \
  -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/dSYMs/${FRAMEWORK_NAME__ADJUST_WEB_BRIDGE}.dSYM" \
  ${WEB_IOS_BCSYMBOLS} \
  -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_WEB_BRIDGE}" \
  -debug-symbols "$(pwd -P)/${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/dSYMs/${FRAMEWORK_NAME__ADJUST_WEB_BRIDGE}.dSYM" \
  -output "./${XCF_OUTPUT_FOLDER}/${XCF_NAME__WEB_BRIDGE}"

else

  xcodebuild -create-xcframework \
  -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_WEB_BRIDGE}" \
  -framework "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME__ADJUST_WEB_BRIDGE}" \
  -output "./${XCF_OUTPUT_FOLDER}/${XCF_NAME__WEB_BRIDGE}"

fi

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding static XCFramework for iOS..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

xcodebuild -configuration Release \
-target Adjust \
-sdk iphonesimulator \
build

xcodebuild -configuration Release \
-target Adjust \
-sdk iphoneos \
build

xcodebuild -configuration Release \
-target AdjustSdkTvStatic \
-sdk appletvsimulator \
build

xcodebuild -configuration Release \
-target AdjustSdkTvStatic \
-sdk appletvos \
build

xcodebuild -create-xcframework \
-library build/Release-iphoneos/libAdjust.a -headers build/Release-iphoneos/include \
-library build/Release-iphonesimulator/libAdjust.a -headers build/Release-iphonesimulator/include \
-library build/Release-appletvos/libAdjustSdkTvStatic.a -headers build/Release-appletvos/include \
-library build/Release-appletvsimulator/libAdjustSdkTvStatic.a -headers build/Release-appletvsimulator/include \
-output "./${XCF_OUTPUT_FOLDER}/${XCF_NAME__IOS_STATIC}"

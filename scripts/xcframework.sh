# Output folder for frameworks and xcframeworks
XCF_OUTPUT_FOLDER="sdk_distribution"
XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER="xcframeworks-dynamic"
XCF_OUTPUT_STATIC_XCFRMK_FOLDER="xcframeworks-static"
XCF_OUTPUT_DYNAMIC_FRMK_FOLDER="frameworks-dynamic"
XCF_OUTPUT_STATIC_FRMK_FOLDER="frameworks-static"

# SDK Schema names - Dynamic
SCHEMA_NAME__ADJUST_IOS="AdjustSdk"
SCHEMA_NAME__ADJUST_TV="AdjustSdkTv"
SCHEMA_NAME__ADJUST_IM="AdjustSdkIm"
SCHEMA_NAME__ADJUST_WEB_BRIDGE="AdjustSdkWebBridge"

# SDK Schema names - Static
SCHEMA_NAME__ADJUST_IOS_STATIC="AdjustSdkStatic"
SCHEMA_NAME__ADJUST_TV_STATIC="AdjustSdkTvStatic"
SCHEMA_NAME__ADJUST_IM_STATIC="AdjustSdkImStatic"
SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC="AdjustSdkWebBridgeStatic"

# SDK frameworks and xcframework names
XCF_FRM_NAME__ADJUST_IOS="AdjustSdk"
XCF_FRM_NAME__ADJUST_TV="AdjustSdkTv"
XCF_FRM_NAME__ADJUST_IM="AdjustSdkIm"
XCF_FRM_NAME__ADJUST_WEB_BRIDGE="AdjustSdkWebBridge"

# xcode archive names
ARCHIVE_NAME__IOS_DEVICE="AdjustSdk-Device"
ARCHIVE_NAME__IOS_SIMULATOR="AdjustSdk-Simulator"
ARCHIVE_NAME__TV_DEVICE="AdjustSdkTv-Device"
ARCHIVE_NAME__TV_SIMULATOR="AdjustSdkTv-Simulator"
ARCHIVE_NAME__IM_DEVICE="AdjustSdkIm-Device"
ARCHIVE_NAME__IM_SIMULATOR="AdjustSdkIm-Simulator"
ARCHIVE_NAME__WEB_DEVICE="AdjustSdkWebBridge-Device"
ARCHIVE_NAME__WEB_SIMULATOR="AdjustSdkWebBridge-Simulator"

# XCFrameworks and Frameworks archive (ZIP) names
XCF_FRM_ZIP_NAME__IOS_TV_DYNAMIC="AdjustSdk-iOS-tvOS-Dynamic"
XCF_FRM_ZIP_NAME__IOS_TV_STATIC="AdjustSdk-iOS-tvOS-Static"
XCF_FRM_ZIP_NAME__IOS_DYNAMIC="AdjustSdk-iOS-Dynamic"
XCF_FRM_ZIP_NAME__IOS_STATIC="AdjustSdk-iOS-Static"
XCF_FRM_ZIP_NAME__TV_DYNAMIC="AdjustSdk-tvOS-Dynamic"
XCF_FRM_ZIP_NAME__TV_STATIC="AdjustSdk-tvOS-Static"
XCF_FRM_ZIP_NAME__IM_DYNAMIC="AdjustSdk-iMessage-Dynamic"
XCF_FRM_ZIP_NAME__IM_STATIC="AdjustSdk-iMessage-Static"
XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC="AdjustSdk-WebBridge-iOS-Dynamic"
XCF_FRM_ZIP_NAME__WEB_BRIDGE_STATIC="AdjustSdk-WebBridge-iOS-Static"


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

  local target_scheme="$1"
  local target_sdk="$2"
  local platform_destination="$3"
  local output_path="$4"

  echo "XCFramework: Building $target_scheme - $target_sdk Archive..."

  xcodebuild clean archive \
  -scheme "$target_scheme" \
  -configuration Release \
  -sdk "$target_sdk" \
  -destination "$platform_destination" \
  -archivePath "$output_path" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  GCC_GENERATE_DEBUGGING_SYMBOLS=YES

}

function generate_bcsymbols_command_parameter() {
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


function archive_framework() {

  local input_folder="$1"
  local input_file="$2"
  local output_file="$3"

  cd "$input_folder"
  zip -r -X "$output_file" "$input_file"
  rm -rf "$input_file"
  cd -
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

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Building Xcode archives for iOS and tvOS..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_archive "${SCHEMA_NAME__ADJUST_IOS}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}"
build_archive "${SCHEMA_NAME__ADJUST_IOS}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}"
build_archive "${SCHEMA_NAME__ADJUST_TV}" "appletvos" "generic/platform=tvOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}"
build_archive "${SCHEMA_NAME__ADJUST_TV}" "appletvsimulator" "generic/platform=tvOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}"

IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__IOS_DEVICE}" "${XCF_OUTPUT_FOLDER}")
TV_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__TV_DEVICE}" "${XCF_OUTPUT_FOLDER}")

# Create XCFramework
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Creating Dynamic XCFramework for iOS and tvOS..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

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

# Cleanup archive files
rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_DEVICE}.xcarchive"
rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IOS_SIMULATOR}.xcarchive"
rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_DEVICE}.xcarchive"
rm -rf "./${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__TV_SIMULATOR}.xcarchive"

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Archiving (ZIP) Dynamic XCFramework for iOS and tvOS..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IOS}.xcframework" "${XCF_FRM_ZIP_NAME__IOS_TV_DYNAMIC}.xcframework.zip"

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Building Xcode archives for iOS (iMessage)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_archive "${SCHEMA_NAME__ADJUST_IM}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_DEVICE}"
build_archive "${SCHEMA_NAME__ADJUST_IM}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__IM_SIMULATOR}"

IM_IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__IM_DEVICE}" "${XCF_OUTPUT_FOLDER}")

# Create XCFramework
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Creating Dynamic XCFramework for iOS (iMessage)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

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

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Archiving (ZIP) Dynamic XCFramework for iOS (iMessage)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IM}.xcframework" "${XCF_FRM_ZIP_NAME__IM_DYNAMIC}.xcframework.zip"

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Building Xcode archives for iOS (WebBridge)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_archive "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "iphoneos" "generic/platform=iOS" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_DEVICE}"
build_archive "${SCHEMA_NAME__ADJUST_WEB_BRIDGE}" "iphonesimulator" "generic/platform=iOS Simulator" "${XCF_OUTPUT_FOLDER}/${ARCHIVE_NAME__WEB_SIMULATOR}"

WEB_IOS_BCSYMBOLS=$(generate_bcsymbols_command_parameter "${ARCHIVE_NAME__WEB_DEVICE}" "${XCF_OUTPUT_FOLDER}")

# Create XCFramework
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Creating Dynamic XCFramework for iOS (WebBridge)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

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

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Archiving (ZIP) Dynamic XCFramework for iOS (WebBridge)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework" "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC}.xcframework.zip"

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding Static XCFramework for iOS and tvOS..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

xcodebuild -configuration Release \
-target "${SCHEMA_NAME__ADJUST_IOS_STATIC}" \
-sdk iphonesimulator \
build

xcodebuild -configuration Release \
-target "${SCHEMA_NAME__ADJUST_IOS_STATIC}" \
-sdk iphoneos \
build

xcodebuild -configuration Release \
-target "${SCHEMA_NAME__ADJUST_TV_STATIC}" \
-sdk appletvsimulator \
build

xcodebuild -configuration Release \
-target "${SCHEMA_NAME__ADJUST_TV_STATIC}" \
-sdk appletvos \
build

xcodebuild -create-xcframework \
-framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphoneos/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
-framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}/iphonesimulator/${XCF_FRM_NAME__ADJUST_IOS}.framework" \
-framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvos/${XCF_FRM_NAME__ADJUST_TV}.framework" \
-framework "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}/appletvsimulator/${XCF_FRM_NAME__ADJUST_TV}.framework" \
-output "./${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}/${XCF_FRM_NAME__ADJUST_IOS}.xcframework"

# Cleanup built frameworks
rm -rf "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_IOS_STATIC}"
rm -rf "./${XCF_OUTPUT_FOLDER}/${SCHEMA_NAME__ADJUST_TV_STATIC}"

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Archiving (ZIP) Static XCFramework for iOS and tvOS..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IOS}.xcframework" "${XCF_FRM_ZIP_NAME__IOS_TV_STATIC}.xcframework.zip"

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding Static XCFramework for iOS (iMessage)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

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

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Archiving (ZIP) Static XCFramework for iOS (iMessage)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_IM}.xcframework" "${XCF_FRM_ZIP_NAME__IM_STATIC}.xcframework.zip"

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding Static XCFramework for iOS (WebBridge)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

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

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Archiving (ZIP) Static XCFramework for iOS (WebBridge)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
archive_framework "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_XCFRMK_FOLDER}" "${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}.xcframework" "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_STATIC}.xcframework.zip"

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding standalone fat static frameworks"
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
# Build Fat Frameworks (without arm64 arch for a simulator)

# Build, Lipo an Zip framework function
function build_static_fat_framework() {
  # Prameters:
  # 1 - Target scheme name
  # 2 - Target OS ('ios', 'tvos')
  # 3 - Resulting SDK Framework name
  # 4 - SDK scheme build root folder
  # 5 - Framework output folder
  # 6 - Zip archive name

  local target_scheme="$1"
  local os="$2"
  local framework_name="$3"
  local build_root_folder="$4"
  local output_folder="$5"
  local zip_file_name="$6"


  echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
  echo "Target Scheme - $target_scheme"
  echo "Target OS - $os"
  echo "Resulting SDK Framework name - $framework_name"
  echo "SDK scheme build root folder - $build_root_folder"
  echo "Framework output folder - $output_folder"
  echo "Zip file name - $zip_file_name"
  echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

  xcodebuild clean

  if [[ $os == "ios" ]]; then
    
    xcodebuild -configuration Release \
    -target "$target_scheme" \
    -sdk iphonesimulator \
    -arch x86_64 -arch i386 \
    build

    xcodebuild -configuration Release \
    -target "$target_scheme" \
    -sdk iphoneos \
    build

    ditto "./$build_root_folder/$target_scheme/iphoneos/$framework_name.framework" "./$build_root_folder/$target_scheme/universal/$framework_name.framework"

    xcrun lipo -create \
    "./$build_root_folder/$target_scheme/iphoneos/$framework_name.framework/Versions/A/$framework_name" \
    "./$build_root_folder/$target_scheme/iphonesimulator/$framework_name.framework/Versions/A/$framework_name" \
    -output "./$build_root_folder/$target_scheme/universal/$framework_name.framework/Versions/A/$framework_name"



  elif [[ $os == "tvos" ]]; then

    xcodebuild -configuration Release \
    -target "$target_scheme" \
    -sdk appletvsimulator \
    -arch x86_64 \
    build

    xcodebuild -configuration Release \
    -target "$target_scheme" \
    -sdk appletvos \
    build

    ditto "./$build_root_folder/$target_scheme/appletvos/$framework_name.framework" "./$build_root_folder/$target_scheme/universal/$framework_name.framework"

    xcrun lipo -create \
    "./$build_root_folder/$target_scheme/appletvos/$framework_name.framework/Versions/A/$framework_name" \
    "./$build_root_folder/$target_scheme/appletvsimulator/$framework_name.framework/Versions/A/$framework_name" \
    -output "./$build_root_folder/$target_scheme/universal/$framework_name.framework/Versions/A/$framework_name"

  else   

    echo "ERROR: Unsupported OS type!"
    return 1

  fi
  
  cd "$build_root_folder/$target_scheme/universal"
  zip -r -X "$zip_file_name" "$framework_name.framework"
  cd -
  mv "$build_root_folder/$target_scheme/universal/$zip_file_name" "$output_folder"
  rm -rf "$build_root_folder/$target_scheme"

}

mkdir -p "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}"

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding Static Frameworks for iOS..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_static_fat_framework "${SCHEMA_NAME__ADJUST_IOS_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_IOS}" "${XCF_OUTPUT_FOLDER}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}" "${XCF_FRM_ZIP_NAME__IOS_STATIC}.framework.zip"

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding static Frameworks for tvOS..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_static_fat_framework "${SCHEMA_NAME__ADJUST_TV_STATIC}" "tvos" "${XCF_FRM_NAME__ADJUST_TV}" "${XCF_OUTPUT_FOLDER}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}" "${XCF_FRM_ZIP_NAME__TV_STATIC}.framework.zip"

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding static Frameworks for iOS (iMessage)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_static_fat_framework "${SCHEMA_NAME__ADJUST_IM_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_IM}" "${XCF_OUTPUT_FOLDER}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}" "${XCF_FRM_ZIP_NAME__IM_STATIC}.framework.zip"

echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "XCFramework: Buiding static Frameworks for iOS (WebBridge)..."
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
build_static_fat_framework "${SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC}" "ios" "${XCF_FRM_NAME__ADJUST_WEB_BRIDGE}" "${XCF_OUTPUT_FOLDER}" "${XCF_OUTPUT_FOLDER}/${XCF_OUTPUT_STATIC_FRMK_FOLDER}" "${XCF_FRM_ZIP_NAME__WEB_BRIDGE_STATIC}.framework.zip"


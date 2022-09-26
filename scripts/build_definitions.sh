#!/usr/bin/env bash

if [ -z ${NC+x} ]; then 
	# Colors for output
	NC='\033[0m'
	RED='\033[0;31m'
	CYAN='\033[1;36m'
	GREEN='\033[0;32m'
	YELLOW='\033[1;33m'
fi

if [ -z ${XCF_OUTPUT_FOLDER+x} ]; then 
  	
  	echo "Executing the definitions script..."; 
  	set -o pipefail

  	function usage(){

  		echo -e "${RED}[ADJUST][BUILD]:${GREEN} 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Usage: $0 [options]

* Use [-all] argument to build all Build Types for all Platform Targets and Test Framework

* For a certain Build Types, specify any of the following arguments:

	Build Types:

	[-fs]           Build static library frameworks
	[-fd]           Build dynamic library frameworks
	[-xs]           Build static library xcframeworks
	[-xd]           Build dynamic library xcframeworks

* For a certain Platform Targets, specify any of the following arguments:

	Platform Targets:

	[-ios]          iOS platform target
	[-tv]           tvOS platform target
	[-im]           iMessaging platform target
	[-web]          Web-Bridge platform target

* If none of Platform Target arguments is specified, all Platform Targets are built.

* For a Test Framework, specify the following argument:

	[-test]			Test Framework

* Examples:

1. To build all variants, run the following:
   ./scripts/build_frameworks.sh -all

   The following command has the same result as [-all] flag usage:
   ./scripts/build_frameworks.sh -fs -fd -xs -xd -ios -tv -im -web

2. To build static frameworks and xcframeworks for iOS and tvOS only:
   ./scripts/build_frameworks.sh -fs -xs -ios -tv
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -${NC}"

		exit 1
  	}


	BUILD_DYNAMIC_FRAMEWORK=0
	BUILD_STATIC_FRAMEWORK=0
	BUILD_DYNAMIC_XCFRAMEWORK=0
	BUILD_STATIC_XCFRAMEWORK=0
	BUILD_TARGET_IOS=0
	BUILD_TARGET_TVOS=0
	BUILD_TARGET_IM=0
	BUILD_TARGET_WEB_BRIDGE=0
	BUILD_TEST_FRAMEWORK=0
	BUILD_ALL=0

	for an_arg in "$@" ; do
	   case "$an_arg" in
	     '-fd') BUILD_DYNAMIC_FRAMEWORK=1
	       ;;
	     '-fs') BUILD_STATIC_FRAMEWORK=1
	       ;;
	     '-xd') BUILD_DYNAMIC_XCFRAMEWORK=1
	       ;;
	     '-xs') BUILD_STATIC_XCFRAMEWORK=1
	       ;;
	     '-ios') BUILD_TARGET_IOS=1
	       ;;
	     '-tv') BUILD_TARGET_TVOS=1
	       ;;
	     '-im') BUILD_TARGET_IM=1
	       ;;
	     '-web') BUILD_TARGET_WEB_BRIDGE=1
	       ;;
	     '-test') BUILD_TEST_FRAMEWORK=1
		   ;;
	     '-all') BUILD_ALL=1
		   ;;
	   esac
	done

	if [[ BUILD_ALL -eq 1 ]]
	then
		BUILD_DYNAMIC_FRAMEWORK=1
		BUILD_STATIC_FRAMEWORK=1
		BUILD_DYNAMIC_XCFRAMEWORK=1
		BUILD_STATIC_XCFRAMEWORK=1
		BUILD_TARGET_IOS=1
		BUILD_TARGET_TVOS=1
		BUILD_TARGET_IM=1
		BUILD_TARGET_WEB_BRIDGE=1
		BUILD_TEST_FRAMEWORK=1
	fi

	if [[ $BUILD_DYNAMIC_FRAMEWORK -eq 0 ]] && [[ $BUILD_STATIC_FRAMEWORK -eq 0 ]] && [[ $BUILD_DYNAMIC_XCFRAMEWORK -eq 0 ]] && [[ $BUILD_STATIC_XCFRAMEWORK -eq 0 ]] && [[ $BUILD_TEST_FRAMEWORK -eq 0 ]]
	then
		usage
	fi

	if [[ $BUILD_TARGET_IOS -eq 0 ]] && [[ $BUILD_TARGET_TVOS -eq 0 ]] && [[ $BUILD_TARGET_IM -eq 0 ]] && [[ $BUILD_TARGET_WEB_BRIDGE -eq 0 ]] 
	then
		# If no platform variant is provided, all platform variants will be built.
		BUILD_TARGET_IOS=1
		BUILD_TARGET_TVOS=1
		BUILD_TARGET_IM=1
		BUILD_TARGET_WEB_BRIDGE=1
	fi
	
	echo "BUILD_DYNAMIC_FRAMEWORK: $BUILD_DYNAMIC_FRAMEWORK";
	echo "BUILD_STATIC_FRAMEWORK: $BUILD_STATIC_FRAMEWORK";
	echo "BUILD_DYNAMIC_XCFRAMEWORK: $BUILD_DYNAMIC_XCFRAMEWORK";
	echo "BUILD_STATIC_XCFRAMEWORK: $BUILD_STATIC_XCFRAMEWORK";
	echo "BUILD_TARGET_IOS: $BUILD_TARGET_IOS";
	echo "BUILD_TARGET_TVOS: $BUILD_TARGET_TVOS";
	echo "BUILD_TARGET_IM: $BUILD_TARGET_IM";
	echo "BUILD_TARGET_WEB_BRIDGE: $BUILD_TARGET_WEB_BRIDGE";
	echo "BUILD_TEST_FRAMEWORK: $BUILD_TEST_FRAMEWORK";


	# Output folder for frameworks and xcframeworks
	XCF_OUTPUT_FOLDER="sdk_distribution"
	XCF_OUTPUT_DYNAMIC_XCFRMK_FOLDER="xcframeworks-dynamic"
	XCF_OUTPUT_STATIC_XCFRMK_FOLDER="xcframeworks-static"
	XCF_OUTPUT_DYNAMIC_FRMK_FOLDER="frameworks-dynamic"
	XCF_OUTPUT_STATIC_FRMK_FOLDER="frameworks-static"
	XCF_OUTPUT_STATIC_TEST_FRMK_FOLDER="test-static-framework"

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
	XCF_FRM_ZIP_NAME__WEB_BRIDGE_DYNAMIC="AdjustSdk-WebBridge-Dynamic"
	XCF_FRM_ZIP_NAME__WEB_BRIDGE_STATIC="AdjustSdk-WebBridge-Static"


	# previous builds artefacts cleanup 
	rm -rf ${XCF_OUTPUT_FOLDER}
	mkdir ${XCF_OUTPUT_FOLDER}

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
	  zip -r -X -y "$output_file" "$input_file"
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

	SDK_VERSION=$(head -n 1 VERSION)
	echo "$SDK_VERSION"

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
	  zip -r -X -y "$zip_file_name" "$framework_name.framework"
	  cd -
	  mv "$build_root_folder/$target_scheme/universal/$zip_file_name" "$output_folder"
	  mv "$build_root_folder/$target_scheme/universal/$framework_name.framework" "$output_folder"
	  rm -rf "$build_root_folder/$target_scheme"

	}
else 
  # echo "The definitions script has been already executed. Skipping it..."; 
  echo -e "${CYAN}[ADJUST][BUILD]:${YELLOW} The definitions script has been already executed. Skipping it... ${NC}"

fi


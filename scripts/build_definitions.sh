#!/usr/bin/env bash

if [ -z ${NC+x} ]; then
    # Colors for output
    NC='\033[0m'
    RED='\033[0;31m'
    CYAN='\033[1;36m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
fi

if [ -z ${XCF_OUTPUT_ROOT_FOLDER+x} ]; then

    echo "Executing the definitions script...";
    set -o pipefail

    function usage(){

        echo -e "${RED}[ADJUST][BUILD]: Missing parameters!${GREEN}
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
    [-odm]          Build ODM plugin framework

* If none of Platform Target arguments is specified, all Platform Targets are built.

* For a Test Framework, specify the following argument:

    [-test]            Test Framework for iOS Device Only
    [-test-sim]        Test Framework for iOS Simulator Only

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
    BUILD_TARGET_ODM_FRAMEWORK=0
    BUILD_TEST_FRAMEWORK=0
    BUILD_TEST_FRAMEWORK_SIM=0
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
         '-odm') BUILD_TARGET_ODM_FRAMEWORK=1
           ;;
         '-test') BUILD_TEST_FRAMEWORK=1
           ;;
         '-test-sim') BUILD_TEST_FRAMEWORK_SIM=1
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
        BUILD_TARGET_ODM_FRAMEWORK=1
        BUILD_TEST_FRAMEWORK=1
        BUILD_TEST_FRAMEWORK_SIM=1
    fi

    if [[ $BUILD_DYNAMIC_FRAMEWORK -eq 0 ]] && [[ $BUILD_STATIC_FRAMEWORK -eq 0 ]] && [[ $BUILD_DYNAMIC_XCFRAMEWORK -eq 0 ]] && [[ $BUILD_STATIC_XCFRAMEWORK -eq 0 ]]
    then
      if [[ $BUILD_TARGET_IOS -eq 1 ]] || [[ $BUILD_TARGET_TVOS -eq 1 ]] || [[ $BUILD_TARGET_IM -eq 1 ]] || [[ $BUILD_TARGET_WEB_BRIDGE -eq 1 ]] || [[ $BUILD_TARGET_ODM_FRAMEWORK -eq 1 ]]
      then
        BUILD_DYNAMIC_FRAMEWORK=1
        BUILD_STATIC_FRAMEWORK=1
        BUILD_DYNAMIC_XCFRAMEWORK=1
        BUILD_STATIC_XCFRAMEWORK=1
      elif [[ $BUILD_TEST_FRAMEWORK -eq 0 ]] && [[ $BUILD_TEST_FRAMEWORK_SIM -eq 0 ]]
      then
        usage
      fi
    fi

    if [[ $BUILD_DYNAMIC_FRAMEWORK -eq 1 ]] || [[ $BUILD_STATIC_FRAMEWORK -eq 1 ]] || [[ $BUILD_DYNAMIC_XCFRAMEWORK -eq 1 ]] || [[ $BUILD_STATIC_XCFRAMEWORK -eq 1 ]]
    then
      if [[ $BUILD_TARGET_IOS -eq 0 ]] && [[ $BUILD_TARGET_TVOS -eq 0 ]] && [[ $BUILD_TARGET_IM -eq 0 ]] && [[ $BUILD_TARGET_WEB_BRIDGE -eq 0 ]] && [[ $BUILD_TARGET_ODM_FRAMEWORK -eq 0 ]]
      then
          # If no platform variant is provided for one of the framework build targets, all platform variants will be built.
          BUILD_TARGET_IOS=1
          BUILD_TARGET_TVOS=1
          BUILD_TARGET_IM=1
          BUILD_TARGET_WEB_BRIDGE=1
          BUILD_TARGET_ODM_FRAMEWORK=1
      fi
    fi        



    echo "BUILD_DYNAMIC_FRAMEWORK: $BUILD_DYNAMIC_FRAMEWORK";
    echo "BUILD_STATIC_FRAMEWORK: $BUILD_STATIC_FRAMEWORK";
    echo "BUILD_DYNAMIC_XCFRAMEWORK: $BUILD_DYNAMIC_XCFRAMEWORK";
    echo "BUILD_STATIC_XCFRAMEWORK: $BUILD_STATIC_XCFRAMEWORK";
    echo "BUILD_TARGET_IOS: $BUILD_TARGET_IOS";
    echo "BUILD_TARGET_TVOS: $BUILD_TARGET_TVOS";
    echo "BUILD_TARGET_IM: $BUILD_TARGET_IM";
    echo "BUILD_TARGET_WEB_BRIDGE: $BUILD_TARGET_WEB_BRIDGE";
    echo "BUILD_TARGET_ODM_FRAMEWORK: $BUILD_TARGET_ODM_FRAMEWORK";
    echo "BUILD_TEST_FRAMEWORK: $BUILD_TEST_FRAMEWORK";
    echo "BUILD_TEST_FRAMEWORK_SIM: $BUILD_TEST_FRAMEWORK_SIM";


    # Output root folder name
    XCF_OUTPUT_ROOT_FOLDER="sdk_distribution"

    # Output root folder names for frameworks and xcframeworks 
    XCF_OUTPUT_DYNAMIC_XCFRMKS_FOLDER="xcframeworks-dynamic"
    XCF_OUTPUT_STATIC_XCFRMKS_FOLDER="xcframeworks-static"
    XCF_OUTPUT_DYNAMIC_FRMKS_FOLDER="frameworks-dynamic"
    XCF_OUTPUT_STATIC_FRMKS_FOLDER="frameworks-static"

    # Static 
    XCF_OUTPUT_FRMK_IOS_TV_FOLDER_STATIC="AdjustSdk-iOS-tvOS-Static"
    XCF_OUTPUT_FRMK_IOS_FOLDER_STATIC="AdjustSdk-iOS-Static"
    XCF_OUTPUT_FRMK_TV_FOLDER_STATIC="AdjustSdk-tvOS-Static"
    XCF_OUTPUT_FRMK_IM_FOLDER_STATIC="AdjustSdk-iMessage-Static"
    XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_STATIC="AdjustSdk-WebBridge-Static"
    XCF_OUTPUT_FRMK_ODM_FOLDER_STATIC="AdjustOdmPlugin-Static"

    # Dynamic
    XCF_OUTPUT_FRMK_IOS_TV_FOLDER_DYNAMIC="AdjustSdk-iOS-tvOS-Dynamic"
    XCF_OUTPUT_FRMK_IOS_FOLDER_DYNAMIC="AdjustSdk-iOS-Dynamic"
    XCF_OUTPUT_FRMK_TV_FOLDER_DYNAMIC="AdjustSdk-tvOS-Dynamic"
    XCF_OUTPUT_FRMK_IM_FOLDER_DYNAMIC="AdjustSdk-iMessage-Dynamic"
    XCF_OUTPUT_FRMK_WEB_BRIDGE_FOLDER_DYNAMIC="AdjustSdk-WebBridge-Dynamic"
    XCF_OUTPUT_FRMK_ODM_FOLDER_DYNAMIC="AdjustOdmPlugin-Dynamic"

    # SDK Schema names - Dynamic
    SCHEMA_NAME__ADJUST_IOS="AdjustSdk"
    SCHEMA_NAME__ADJUST_TV="AdjustSdkTv"
    SCHEMA_NAME__ADJUST_IM="AdjustSdkIm"
    SCHEMA_NAME__ADJUST_WEB_BRIDGE="AdjustSdkWebBridge"
    SCHEMA_NAME__ODM_DYNAMIC="AdjustOdmPlugin"

    # SDK Schema names - Static
    SCHEMA_NAME__ADJUST_IOS_STATIC="AdjustSdkStatic"
    SCHEMA_NAME__ADJUST_TV_STATIC="AdjustSdkTvStatic"
    SCHEMA_NAME__ADJUST_IM_STATIC="AdjustSdkImStatic"
    SCHEMA_NAME__ADJUST_WEB_BRIDGE_STATIC="AdjustSdkWebBridgeStatic"
    SCHEMA_NAME__ODM_STATIC="AdjustOdmPluginStatic"

    # SDK frameworks and xcframework names
    XCF_FRM_NAME__ADJUST_IOS="AdjustSdk"
    XCF_FRM_NAME__ADJUST_TV="AdjustSdk"
    XCF_FRM_NAME__ADJUST_IM="AdjustSdk"
    XCF_FRM_NAME__ADJUST_WEB_BRIDGE="AdjustSdk"
    XCF_FRM_NAME__ADJUST_ODM="AdjustOdmPlugin"

    # xcode archive names
    ARCHIVE_NAME__IOS_DEVICE="AdjustSdk-Device"
    ARCHIVE_NAME__IOS_SIMULATOR="AdjustSdk-Simulator"
    ARCHIVE_NAME__TV_DEVICE="AdjustSdkTv-Device"
    ARCHIVE_NAME__TV_SIMULATOR="AdjustSdkTv-Simulator"
    ARCHIVE_NAME__IM_DEVICE="AdjustSdkIm-Device"
    ARCHIVE_NAME__IM_SIMULATOR="AdjustSdkIm-Simulator"
    ARCHIVE_NAME__WEB_DEVICE="AdjustSdkWebBridge-Device"
    ARCHIVE_NAME__WEB_SIMULATOR="AdjustSdkWebBridge-Simulator"
    ARCHIVE_NAME__ODM_DEVICE="AdjustOdmPlugin-Device"
    ARCHIVE_NAME__ODM_SIMULATOR="AdjustOdmPlugin-Simulator"

    # Xcode version impacts the way we build frameworks
    XCODE12PLUS=0
    XCODE14PLUS=0
    product_version=$(xcodebuild -version)
    xcode_version=( ${product_version//./ } )
    xcode="${xcode_version[0]}"
    major="${xcode_version[1]}"
    minor="${xcode_version[2]}"
    echo "${xcode}.${major}.${minor}"
    if [[ $major > 11 ]]; then
      XCODE12PLUS=1
    fi
    if [[ $major > 13 ]]; then
      XCODE14PLUS=1
    fi

    SDK_VERSION=$(head -n 1 VERSION)
    echo "$SDK_VERSION"

    # dynamic xcframework signing identity
    SDK_CODE_SIGN_IDENTITY="Apple Distribution: adeven GmbH (QGUGW9AUMK)"

    # previous builds artefacts cleanup
    rm -rf ${XCF_OUTPUT_ROOT_FOLDER}
    mkdir ${XCF_OUTPUT_ROOT_FOLDER}

    # previous xcode build folder cleanup
    xcodebuild clean

    # Build a target (scheme) and create an xcode archive
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
      BCSYMBOLMAP_PATHS=" "
      if [[ $XCODE14PLUS == 0 ]]; then
        BCSYMBOLMAP_PATHS=("$(pwd -P)"/$2/$1.xcarchive/BCSymbolMaps/*)
        BCSYMBOLMAP_COMMANDS=""
        for path in "${BCSYMBOLMAP_PATHS[@]}"; do
          BCSYMBOLMAP_COMMANDS="$BCSYMBOLMAP_COMMANDS -debug-symbols $path "
        done
      fi
      echo $BCSYMBOLMAP_COMMANDS
    }

    # Make a zip archive 
    function archive_framework() {

      local input_folder="$1"
      local input_file="$2"
      local output_file="$3"

      cd "$input_folder"
      zip -r -X -y "$output_file" "$input_file"
      cd -
    }

    function build_dynamic_fat_framework() {

      # Prameters:
      # 1 - Target scheme name
      # 2 - Target OS ('ios', 'tvos')
      # 3 - Resulting SDK Framework name
      # 4 - SDK scheme build root folder
      # 5 - Framework output folder
      # 6 - Zip archive name

      local target_schema_name="$1"
      local os_platform="$2"
      local resulting_framework_name="$3"
      local build_root_folder="$4"
      local output_folder="$5"
      local zip_file_name="$6"

      echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="
      echo "Target Scheme - $target_schema_name"
      echo "Target OS - $os_platform"
      echo "Resulting SDK Framework name - $resulting_framework_name"
      echo "SDK scheme build root folder - $build_root_folder"
      echo "Framework output folder - $output_folder"
      echo "Zip file name - $zip_file_name"
      echo "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ="

      xcodebuild clean
      local temp_build_folder="${build_root_folder}/_build"
      rm -rf "${temp_build_folder}"

      local device_sdk_name=""
      local simulator_sdk_name=""
      local device_framework=""
      local sim_framework=""
      local universal_dir=""
      local universal_framework=""
      local universal_framework_dsym=""

      if [[ $os_platform == "ios" ]]; then

        device_sdk_name="iphoneos"
        simulator_sdk_name="iphonesimulator"

      elif [[ $os_platform == "tvos" ]]; then

        device_sdk_name="appletvos"
        simulator_sdk_name="appletvsimulator"

      else

        echo "ERROR: Unsupported OS type!"
        return 1

      fi

      # Build simulator target
      xcodebuild -configuration Release \
      -target "${target_schema_name}" \
      -sdk "${simulator_sdk_name}" \
      EXCLUDED_ARCHS=arm64 \
      ONLY_ACTIVE_ARCH=NO \
      BUILD_DIR="${temp_build_folder}" \
      BUILD_ROOT="${temp_build_folder}" \
      OBJROOT="${temp_build_folder}/obj" \
      SYMROOT="${temp_build_folder}" \
      GCC_GENERATE_DEBUGGING_SYMBOLS=YES \
      build

      # Build device target
      xcodebuild -configuration Release \
      -target "${target_schema_name}" \
      -sdk "${device_sdk_name}" \
      BUILD_DIR="${temp_build_folder}" \
      BUILD_ROOT="${temp_build_folder}" \
      OBJROOT="${temp_build_folder}/obj" \
      SYMROOT="${temp_build_folder}" \
      GCC_GENERATE_DEBUGGING_SYMBOLS=YES \
      build

      device_framework="${temp_build_folder}/Release-${device_sdk_name}/${resulting_framework_name}.framework"
      sim_framework="${temp_build_folder}/Release-${simulator_sdk_name}/${resulting_framework_name}.framework"
      universal_dir="${temp_build_folder}/universal"
      universal_framework="${universal_dir}/${resulting_framework_name}.framework"
      universal_framework_dsym="${universal_framework}.dSYM"

      # Create a universal version of the framework
      mkdir -p "${universal_dir}"
      ditto "${device_framework}" "${universal_framework}"
      
      # Create a fat binary
      xcrun lipo -create \
      "${device_framework}/${resulting_framework_name}" \
      "${sim_framework}/${resulting_framework_name}" \
      -output "${universal_framework}/${resulting_framework_name}"

      # Create a dSYM file from the fat framework binary
      dsymutil "${universal_framework}/${resulting_framework_name}" -o "${universal_framework_dsym}"

      # Move framework and dSYM file to the output folder
      mv "${universal_framework}" "${output_folder}"
      mv "${universal_framework_dsym}" "${output_folder}"

      # Zip a fat framework including the containing folder
      local script_run_path="$PWD"
      cd "$output_folder"
      local last_folder=$(basename "$PWD")
      cd ..
      zip -r -X "$zip_file_name" "$last_folder"  
      cd "$script_run_path"

      # Cleanup build folder
      rm -rf "${temp_build_folder}"
    }


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

        if [[ $XCODE14PLUS > 0 ]]; then
          # Xcode14 dropped 32-bit support, so we have to drop 'i386' arc.
          xcodebuild -configuration Release \
          -target "$target_scheme" \
          -sdk iphonesimulator \
          -arch x86_64 \
          build
        else
          xcodebuild -configuration Release \
          -target "$target_scheme" \
          -sdk iphonesimulator \
          -arch x86_64 -arch i386 \
          build
        fi

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

      mv "$build_root_folder/$target_scheme/universal/$framework_name.framework" "$output_folder"
      script_run_path="$PWD"
      cd "$output_folder"
      last_folder=$(basename "$PWD")
      cd ..
      zip -r -X -y "$zip_file_name" "$last_folder/$framework_name.framework"  
      cd "$script_run_path"

      rm -rf "$build_root_folder/$target_scheme"

    }
else
  # echo "The definitions script has been already executed. Skipping it...";
  echo -e "${CYAN}[ADJUST][BUILD]:${YELLOW} The definitions script has been already executed. Skipping it... ${NC}"

fi

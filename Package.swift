// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AdjustSdk",
    products: [
        .library(name: "AdjustSdk", targets: ["AdjustSdk"]),
        .library(name: "AdjustWebBridge", targets: ["AdjustWebBridge", "AdjustSdk"]),
        .library(name: "AdjustSdkGoogleAdsOnDeviceConversion", targets: ["AdjustSdkGoogleAdsOnDeviceConversion", "AdjustSdk"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/adjust/adjust_signature_sdk.git",
            .exact("3.35.2")
        ),
        .package(
            url: "https://github.com/googleads/google-ads-on-device-conversion-ios-sdk.git",
            .from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "AdjustSdk",
            dependencies: [
                .product(name: "AdjustSignature", package: "adjust_signature_sdk")
            ],
            path: "Adjust",
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("Internal")
            ]
        ),
        .target(
            name: "AdjustWebBridge",
            dependencies: [
                .product(name: "AdjustSignature", package: "adjust_signature_sdk")
            ],
            path: "AdjustBridge",
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("../Adjust/include"),
            ]
        ),
        .target(
            name: "AdjustSdkGoogleAdsOnDeviceConversion",
            dependencies: [
                .product(name: "GoogleAdsOnDeviceConversion", package: "google-ads-on-device-conversion-ios-sdk") 
            ],
            path: "plugins/odm",
            sources: [ "headers", "sources/spm"],
            publicHeadersPath: "headers"
        )
    ]
)

// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AdjustSdk",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        .library(name: "AdjustSdk", targets: ["AdjustSdk", "AdjustSdkSigned"]),
        .library(name: "AdjustSdkUnsigned", targets: ["AdjustSdk"]),
        .library(name: "AdjustWebBridge", targets: ["AdjustWebBridge", "AdjustSdk", "AdjustSdkSigned"]),
        .library(name: "AdjustWebBridgeUnsigned", targets: ["AdjustWebBridge", "AdjustSdk"]),
        .library(name: "AdjustGoogleOdm", targets: ["AdjustGoogleOdm", "AdjustSdk", "AdjustSdkSigned"]),
        .library(name: "AdjustGoogleOdmUnsigned", targets: ["AdjustGoogleOdm", "AdjustSdk"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/adjust/adjust_signature_sdk.git",
            .exact("3.61.0")
        ),
        .package(
            url: "https://github.com/googleads/google-ads-on-device-conversion-ios-sdk.git",
            "2.0.0"..<"4.0.0"
        )
    ],
    targets: [
        .target(
            name: "AdjustSdkSigned",
            dependencies: [
                .target(name: "AdjustSdk"),
                .product(name: "AdjustSignature", package: "adjust_signature_sdk")
            ],
            path: "Wrappers/AdjustSdkSigned",
            sources: ["Wrapper.swift"]
        ),
        .target(
            name: "AdjustSdk",
            dependencies: [],
            path: "Adjust",
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("Internal"),
                .headerSearchPath("include")
            ]
        ),
        .target(
            name: "AdjustWebBridge",
            dependencies: [],
            path: "AdjustBridge",
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("../Adjust/include"),
            ]
        ),
        .target(
            name: "AdjustGoogleOdm",
            dependencies: [
                .product(name: "GoogleAdsOnDeviceConversion", package: "google-ads-on-device-conversion-ios-sdk")
            ],
            path: "plugins/odm",
            sources: [ "headers", "sources/spm"],
            publicHeadersPath: "headers"
        )
    ]
)
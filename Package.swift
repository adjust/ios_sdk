// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AdjustSdk",
    products: [
        .library(name: "AdjustSdk", targets: ["AdjustSdk"]),
        .library(name: "AdjustWebBridge", targets: ["AdjustWebBridge", "AdjustSdk"]),
        .library(name: "GoogleOdm", targets: ["GoogleOdm", "AdjustSdk"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/adjust/adjust_signature_sdk.git",
            .exact("3.35.2") 
        ),
        .package(
            url: "https://github.com/google/GoogleUtilities.git",
            .exact("8.1.0") 
        ),
        .package(
            url: "https://github.com/nanopb/nanopb.git",
            revision: "b7e1104502eca3a213b46303391ca4d3bc8ddec1"
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
        .binaryTarget(
            name: "AppAdsOnDeviceConversion",
            path: "plugins/odm/AppAdsOnDeviceConversion.xcframework"
        ),
        .target(
            name: "GoogleOdm",
            dependencies: [
                "AppAdsOnDeviceConversion",
                .product(name: "GULLogger", package: "GoogleUtilities"),
                .product(name: "GULNetwork", package: "GoogleUtilities"),
                .product(name: "nanopb", package: "nanopb") 
            ],
            path: "plugins/odm",
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Adjust"),
                .headerSearchPath("Adjust/ADJAdditions")
            ]
        )
    ]
)

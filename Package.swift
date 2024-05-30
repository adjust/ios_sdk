// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AdjustSdk",
    products: [
        .library(name: "AdjustSdk", targets: ["AdjustSdk"]),
        .library(name: "AdjustWebBridge", targets: ["AdjustWebBridge", "AdjustSdk"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/adjust/adjust_signature_sdk.git",
            from: "3.18.0"
        )
    ],
    targets: [
        .target(
            name: "AdjustSdk",
            dependencies: [
                .product(name: "AdjustSigSdk", package: "adjust_signature_sdk")
            ],
            path: "Adjust",
            exclude: ["Info.plist"],
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
                .product(name: "AdjustSigSdk", package: "adjust_signature_sdk")
            ],
            path: "AdjustBridge",
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("WebViewJavascriptBridge"),
                .headerSearchPath("../Adjust"),
                .headerSearchPath("../Adjust/Internal")
            ]
        ),
    ]
)


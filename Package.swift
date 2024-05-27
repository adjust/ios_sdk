// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AdjustSdk",
    products: [
        .library(name: "AdjustSdk", targets: ["AdjustSdk"]),
        .library(name: "WebBridge", targets: ["WebBridge", "AdjustSdk"])
    ],
    targets: [
        .target(
            name: "AdjustSdk",
            path: "Adjust",
            exclude: ["Info.plist"],
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("ADJAdditions")
            ]
        ),
        .target(
            name: "WebBridge",
            path: "AdjustBridge",
            exclude: ["Adjust"],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("WebViewJavascriptBridge"),
                .headerSearchPath("Adjust"),
            ]
        ),
    ]
)


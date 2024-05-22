// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Adjust",
    products: [
        .library(name: "Adjust", targets: ["Adjust"]),
        .library(name: "WebBridge", targets: ["WebBridge", "Adjust"])
    ],
    targets: [
        .target(
            name: "Adjust",
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

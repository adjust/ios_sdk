// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Adjust",
    products: [
        .library(name: "Adjust", targets: ["Adjust"]),
        .library(name: "Sociomantic", targets: ["Sociomantic", "Adjust"]),
        .library(name: "Criteo", targets: ["Criteo", "Adjust"]),
        .library(name: "Trademob", targets: ["Trademob", "Adjust"]),
        .library(name: "WebBridge", targets: ["WebBridge", "Adjust"])
    ],
    targets: [
        .target(
            name: "Adjust",
            path: "Adjust",
            exclude: ["Info.plist"],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("ADJAdditions")
            ]
        ),
        .target(
            name: "Sociomantic",
            path: "plugin/Sociomantic",
            exclude: ["Adjust"],
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Adjust"),
                .headerSearchPath("Adjust/ADJAdditions")
            ]
        ),
        .target(
            name: "Criteo",
            path: "plugin/Criteo",
            exclude: ["Adjust"],
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Adjust"),
                .headerSearchPath("Adjust/ADJAdditions")
            ]
        ),
        .target(
            name: "Trademob",
            path: "plugin/Trademob",
            exclude: ["Adjust"],
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("Adjust"),
                .headerSearchPath("Adjust/ADJAdditions")
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

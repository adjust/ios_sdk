// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Adjust",
    products: [
        .library(name: "AdjustSdk", targets: ["AdjustSdk"]),
        .library(name: "Sociomantic", targets: ["Sociomantic"]),
        .library(name: "Criteo", targets: ["Criteo"]),
        .library(name: "Trademob", targets: ["Trademob"]),
        .library(name: "WebBridge", targets: ["WebBridge"]),
    ],
    targets: [
        .target(name: "AdjustSdk", dependencies: ["Core"], path: "AdjustSdk"),
        .target(name: "Core", path: "Adjust"),
        .target(name: "Sociomantic", dependencies: ["Core"], path: "plugin/Sociomantic"),
        .target(name: "Criteo", dependencies: ["Core"], path: "plugin/Criteo"),
        .target(name: "Trademob", dependencies: ["Core"], path: "plugin/Trademob"),
        .target(name: "WebBridge", dependencies: ["Core"], path: "AdjustBridge"),
    ]
)

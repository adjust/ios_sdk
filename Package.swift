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
        .target(name: "AdjustSdk", dependencies: ["Core"]),
        .target(name: "Core", path: "Adjust"),
        .target(name: "Sociomantic", path: "plugin/Sociomantic", dependencies: ["Core"]),
        .target(name: "Criteo", path: "plugin/Criteo", dependencies: ["Core"]),
        .target(name: "Trademob", path: "plugin/Trademob", dependencies: ["Core"]),
        .target(name: "WebBridge", path: "AdjustBridge", dependencies: ["Core"]),
    ]
)

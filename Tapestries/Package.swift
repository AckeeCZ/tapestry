// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tapestries",
    products: [
    .library(name: "TapestryConfig", targets: ["TapestryConfig"])
    ],
    dependencies: [
        // Tapestry
        .package(path: "../"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", .upToNextMajor(from: "0.40.13")),
    ],
    targets: [
        .target(name: "TapestryConfig",
                dependencies: [
                    "PackageDescription"
        ])
    ]
)

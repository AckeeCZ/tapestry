// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tapestry",
    products: [
        .library(name: "TapestryGen",
                 targets: ["TapestryGen"]),
        .executable(
            name: "Tapestry",
            targets: ["Tapestry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", .upToNextMinor(from: "5.3.2")),
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "1.0.0")),
        // TODO: Change to .upToNextMinor
        .package(url: "https://github.com/tuist/tuist.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "Tapestry",
            dependencies: [
                "SwiftCLI",
                .target(name: "TapestryGen")
            ]),
        .target(
            name: "TapestryGen",
            dependencies: [
                "SwiftCLI",
                "PathKit",
            ]),
        .testTarget(
            name: "TapestryTests",
            dependencies: ["Tapestry"]),
    ]
)

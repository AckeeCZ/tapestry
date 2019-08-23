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
        .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "1.0.0")),
        // TODO: Change to .upToNextMinor
        .package(url: "https://github.com/fortmarek/tuist.git", .upToNextMinor(from: "0.17.0")),
        .package(url: "https://github.com/apple/swift-package-manager", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/miguelangel-dev/acho", .branch("patch-1")),
    ],
    targets: [
        .target(
            name: "Tapestry",
            dependencies: [
                .target(name: "TapestryGen")
            ]),
        .target(
            name: "TapestryGen",
            dependencies: [
                "PathKit",
                "TuistGenerator",
                "SwiftPM",
                "acho",
            ]),
        .testTarget(
            name: "TapestryTests",
            dependencies: ["Tapestry"]),
    ]
)

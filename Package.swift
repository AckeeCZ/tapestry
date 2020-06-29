// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tapestry",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(name: "TapestryGen",
                 targets: ["TapestryGen"]),
        .library(name: "TapestryDescription",
                 type: .dynamic,
                 targets: ["TapestryDescription"]),
        .executable(
            name: "tapestry",
            targets: ["tapestry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/tuist.git", .branch("rxblocking")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.0.6")),
        .package(url: "https://github.com/IBM-Swift/BlueSignals", .upToNextMajor(from: "1.0.21")),
    ],
    targets: [
        .target(
            name: "tapestry",
            dependencies: [
                "TapestryKit",
        ]),
        .target(name: "TapestryKit",
                dependencies: [
                    "TapestryGen",
                    "TapestryCore",
                    "TapestryDescription",
                    "Signals",
                    "ArgumentParser",
        ]),
        .target(name: "TapestryCore",
                dependencies: [
                    "TuistGenerator",
        ]),
        .target(
            name: "TapestryGen",
            dependencies: [
                "TapestryCore",
        ]),
        .target(
            name: "TapestryDescription"
        ),
        .target(name: "TapestryCoreTesting",
                dependencies: [
                    "TapestryCore",
        ]),
        .testTarget(
            name: "TapestryKitTests",
            dependencies: [
                "TapestryKit",
                "TapestryCoreTesting",
                "TuistGenerator",
                "Signals"
            ]
        ),
        .testTarget(
            name: "TapestryCoreTests",
            dependencies: ["TapestryCore", "TapestryCoreTesting"]),
        .testTarget(
            name: "TapestryGenTests",
            dependencies: ["TapestryGen", "TapestryCoreTesting"]),
        .testTarget(
            name: "TapestryDescriptionTests",
            dependencies: ["TapestryDescription", "TapestryCoreTesting"]),
    ]
)

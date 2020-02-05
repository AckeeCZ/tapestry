// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tapestry",
    products: [
        .library(name: "TapestryGen",
                 targets: ["TapestryGen"]),
        .library(name: "PackageDescription",
                 type: .dynamic,
                 targets: ["PackageDescription"]),
        .executable(
            name: "tapestry",
            targets: ["tapestry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/fortmarek/tuist.git", .branch("master")),
        .package(url: "https://github.com/fortmarek/acho", .branch("spm_bump")),
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
                    "PackageDescription",
                    "Signals",
            ]),
        .target(name: "TapestryCore",
                dependencies: [
                    "acho",
                    "TuistGenerator",
            ]),
        .target(
            name: "TapestryGen",
            dependencies: [
                "TapestryCore",
            ]),
        .target(
            name: "PackageDescription"
        ),
        .target(name: "TapestryCoreTesting",
                dependencies: [
                    "TapestryCore",
            ]),
        .testTarget(
            name: "TapestryKitTests",
            dependencies: ["TapestryKit", "TapestryCoreTesting"]),
        .testTarget(
            name: "TapestryCoreTests",
            dependencies: ["TapestryCore", "TapestryCoreTesting"]),
        .testTarget(
            name: "TapestryGenTests",
            dependencies: ["TapestryGen", "TapestryCoreTesting"]),
        .testTarget(
            name: "PackageDescriptionTests",
            dependencies: ["PackageDescription", "TapestryCoreTesting"]),
    ]
)

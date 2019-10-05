// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tapestry",
    products: [
        .library(name: "TapestryGen",
                 targets: ["TapestryGen"]),
        .executable(
            name: "tapestry",
            targets: ["tapestry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/fortmarek/tuist.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-package-manager", .branch("swift-5.0-RELEASE")),
        .package(url: "https://github.com/miguelangel-dev/acho", .branch("patch-1")),
    ],
    targets: [
        .target(
            name: "tapestry",
            dependencies: [
                .target(name: "TapestryKit")
            ]),
        .target(name: "TapestryKit",
                dependencies: [
                    "SPMUtility",
                    "TapestryGen",
                    "TapestryCore",
            ]),
        .target(name: "TapestryCore",
                dependencies: [
                    "acho",
                    "SPMUtility",
                    "TuistGenerator",
            ]),
        .target(
            name: "TapestryGen",
            dependencies: [
                "SPMUtility",
                "TuistGenerator",
                "TapestryCore",
            ]),
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
            dependencies: ["TapestryGen", "TapestryCoreTesting"])
    ]
)

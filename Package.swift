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
        .package(url: "https://github.com/fortmarek/tuist.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-package-manager", .branch("swift-5.0-RELEASE")),
        .package(url: "https://github.com/miguelangel-dev/acho", .branch("patch-1")),
    ],
    targets: [
        .target(
            name: "Tapestry",
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
                    "SPMUtility"
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
            dependencies: ["TapestryCore"]),
        .testTarget(
            name: "TapestryGenTests",
            dependencies: ["TapestryGen"])
    ]
)

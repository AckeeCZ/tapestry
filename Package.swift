// swift-tools-version:4.2
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
        .package(path: "../../tuist"),
        .package(url: "https://github.com/fortmarek/acho", .branch("spm_bump")),
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

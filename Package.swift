// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let enableDevDepedencies = true

extension Package {
    convenience init(name: String,
                     products: [Product] = [],
                     dependencies: [Package.Dependency] = [],
                     developerDependencies: [Package.Dependency],
                     targets: [Target] = []) {
        let allDependencies = enableDevDepedencies ? dependencies : dependencies + developerDependencies
        self.init(name: name, products: products, dependencies: allDependencies, targets: targets)
    }
}

let package = Package(
    name: "tapestry",
    platforms: [
        .macOS(.v10_10),
    ],
    products: [
        .library(name: "TapestryGen",
                 targets: ["TapestryGen"]),
        .library(name: "TapestryConfiguration",
                 type: .dynamic,
                 targets: ["TapestryConfiguration"]),
        .executable(
            name: "tapestry-config",
            targets: ["TapestryConfigurationExecutable"]), // dev
        .executable(
            name: "tapestry",
            targets: ["tapestry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/tuist.git", .branch("master")),
        .package(url: "https://github.com/fortmarek/acho", .branch("spm_bump")),
    ],
    targets: [
        .target(
            name: "tapestry",
            dependencies: [
                .target(name: "TapestryKit")
            ]),
        .target(name: "TapestryKit",
                dependencies: [
                    "TapestryGen",
                    "TapestryCore",
                    "TapestryConfiguration",
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
            name: "TapestryConfiguration",
            dependencies: [
                "TapestryCore",
        ]),
        .target(name: "TapestryConfigurationExecutable", dependencies: []), // dev
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

#if canImport(TapestryConfiguration)
import TapestryConfiguration

TapestryConfiguration(release:
    ReleaseAction(add: nil,
                  commitMessage: nil,
                  push: false))
    .write()

#endif

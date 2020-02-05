import PackageDescription

let config = TapestryConfig(
    release: Release(actions: [.pre(.docsUpdate),
                               .pre(.dependenciesCompatibility([.spm(.all)])),
                               // Mint support
                                .pre(tool: "swift", arguments: ["build", "-c", "release", "--product", "PackageDescription"]),
                                .pre(tool: "cp", arguments: [".build/release/libPackageDescription.dylib libPackageDescription.dylib"]),
                                .pre(tool: "cp", arguments: [".build/release/PackageDescription.swiftmodule PackageDescription.swiftmodule"]),
                                .pre(tool: "cp", arguments: [".build/release/PackageDescription.swiftdoc PackageDescription.swiftdoc"])],
                     add: ["README.md",
                           "CHANGELOG.md",
                           "libPackageDescription.dylib",
                           "PackageDescription.swiftmodule",
                           "PackageDescription.swiftdoc",],
                     commitMessage: "Version \(Argument.version)",
                     push: false))

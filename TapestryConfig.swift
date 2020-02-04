import PackageDescription

let config = TapestryConfig(
    release: Release(actions: [.pre(.docsUpdate),
                               .pre(.dependenciesCompatibility([.spm(.all)])),
                               // Mint support
                               .pre(tool: "swift", arguments: ["build", "-c", "release", "--product", "PackageDescription"])],
                     add: ["README.md",
                           "CHANGELOG.md",],
                     commitMessage: "Version \(Argument.version)",
                     push: false))

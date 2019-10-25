import PackageDescription

let config = TapestryConfig(
    release: Release(actions: [.pre(.docsUpdate),
                               .pre(.dependenciesCompatibility([.spm(.all)]))],
                     add: ["README.md",
                           "CHANGELOG.md",
                           "Tapestries/Package.resolved"],
                     commitMessage: "Version \(Argument.version)",
                     push: true))

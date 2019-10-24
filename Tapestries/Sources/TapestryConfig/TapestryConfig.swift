import PackageDescription

let config = TapestryConfig(
    release: Release(actions: [.pre(.docsUpdate),
                               .pre(.dependenciesCompatibility([.spm(.all)]))],
                     add: ["README.md"],
                     commitMessage: "Version \(Argument.version)",
                     push: true))

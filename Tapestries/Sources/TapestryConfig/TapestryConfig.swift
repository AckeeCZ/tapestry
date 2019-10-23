import PackageDescription

let config = TapestryConfig(
    release: Release(actions: [.pre(.docsUpdate)],
                     add: ["README.md", "TapestryDemo.podspec"],
                     commitMessage: "Version \(Argument.version)",
                     push: true))

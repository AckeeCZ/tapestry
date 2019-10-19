import PackageDescription

let config = TapestryConfig(
    release: Release(actions: [.pre(.docsUpdate)],
                     add: ["README.md", "TapestryDemo.podspec"],
                     commitMessage: "Version $VERSION",
                     push: true))

import TapestryDescription

let config = TapestryConfig(
    release: Release(
        actions: [
            .pre(.docsUpdate),
            .pre(.dependenciesCompatibility([.spm(.all)])),
            // Mint support
            .pre(tool: "swift", arguments: ["build", "-c", "release", "--product", "TapestryDescription"]),
            .pre(tool: "cp", arguments: ["-rf", ".build/release/libTapestryDescription.dylib", "libTapestryDescription.dylib"]),
            .pre(tool: "cp", arguments: [".build/release/TapestryDescription.swiftmodule", "TapestryDescription.swiftmodule"]),
            .pre(tool: "cp", arguments: [".build/release/TapestryDescription.swiftdoc", "TapestryDescription.swiftdoc"]),
            .post(.githubRelease(owner: "AckeeCZ", repository: "tapestry")),
        ]
        add: [
            "README.md",
            "CHANGELOG.md",
            "libTapestryDescription.dylib",
            "TapestryDescription.swiftmodule",
            "TapestryDescription.swiftdoc",
        ],
        commitMessage: "Version \(Argument.version)",
        push: true)
)


import TapestryDescription

let config = TapestryConfig(
    release: Release(
        actions: [
            .pre(.docsUpdate),
            .pre(.dependenciesCompatibility([.spm(.all)])),
            // Mint support
            .pre(
                tool: "swift",
                arguments: [
                    "build",
                    "-c",
                    "release",
                    "--product",
                    "TapestryDescription",
                    "-Xswiftc",
                    "-enable-library-evolution",
                    "-Xswiftc",
                    "-emit-module-interface",
                    "-Xswiftc",
                    "-emit-module-interface-path",
                    "-Xswiftc",
                    ".build/release/TapestryDescription.swiftinterface",
                ]
            ),
            .pre(tool: "cp", arguments: [".build/release/TapestryDescription.swiftinterface", "TapestryDescription.swiftinteface"]),
            .pre(tool: "cp", arguments: [".build/release/TapestryDescription.swiftmodule", "TapestryDescription.swiftmodule"]),
            .pre(tool: "cp", arguments: [".build/release/TapestryDescription.swiftdoc", "TapestryDescription.swiftdoc"]),
            .post(.githubRelease(owner: "AckeeCZ", repository: "tapestry")),
        ],
        add: [
            "README.md",
            "CHANGELOG.md",
            "TapestryDescription.swiftinterface",
            "TapestryDescription.swiftmodule",
            "TapestryDescription.swiftdoc",
        ],
        commitMessage: "Version \(Argument.version)",
        push: true
    )
)


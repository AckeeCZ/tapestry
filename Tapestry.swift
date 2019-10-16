import TapestryConfig

let config = TapestryConfig(release:
    ReleaseAction(add: nil,
                  commitMessage: nil,
                  push: false))
    .write()

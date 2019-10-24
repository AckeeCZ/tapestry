# Tapestry
[![Build Status](https://travis-ci.com/AckeeCZ/tapestry.svg?branch=master)](https://travis-ci.com/AckeeCZ/tapestry)

## What's Tapestry 🤔

Tapestry helps you with **creating** and **managing** your Swift frameworks 💫

Do you want to easily create a Swift framework that supports Carthage, Cocoapods and Swift Package Manager?

Or define your release steps in a type-safe way?

This is the place to be!

## Installation

### Using [Homebrew](https://brew.sh)

```bash
$ brew tap AckeeCZ/tapestry
$ brew install tapestry
$ tapestry
```

### Using [SPM](https://github.com/apple/swift-package-manager)

Add this to your `Package.swift`:

```swift
.package(url: "https://github.com/AckeeCZ/tapestry.git", .upToNextMajor(from: "0.0.1")),
```

### Using Swift directly

```bash
$ git clone https://github.com/AckeeCZ/tapestry.git
$ cd tapestry
$ swift run tapestry
```

# Generating project

<img alt="Screenshot" src="Resources/tapestry.gif" width="700">


To generate your project, simply run: 
```bash
tapestry init --path TapestryProject
```

You can omit `--path` argument and it will generate your framework in the current directory.

It uses [tuist](https://github.com/tuist/tuist) and [SPM](https://github.com/tuist/tuist) tools, so it's very easy to adjust it to your needs (no complicated template structure, all code is generated from **ground up**!)

You can change the generated files in `InitCommand` and your example project in `ExampleModelLoader`. In the future, I'd like to make this customization even easier, so watch this space 👀

## Generated project features

- [x] `CocoaPods`, `Carthage` and `Swift Package Manager` compatibility
- [x] `README.md` template
- [x] `travis` to automate your builds
- [x] `Library` support
- [x] `Executable` support for your CLI tools
- [ ] more and even more to come!

You can check out an example project that was generated with `tapestry` [here](https://github.com/fortmarek/TapestryDemo).

# Releasing project

<img alt="Screenshot" src="Resources/release.gif" width="700">

## Setup relase steps

To get you started with tapestry (if you did not generate your framework with it!), you can run 
```bash
tapestry up
```

This will create a `tapestries` folder in your repository - it will also from now use `tapestry` version that is defined in `tapestries/Package.swift`. You can add option `--current` to force running your installed version.

To configure your release steps, run:
```bash
tapestry edit
```

This opens Xcode, so you just have to navigate to `TapestryConfig.swift`.

The generated file will look like this:
```swift
import PackageDescription

let config = TapestryConfig(release: Release(actions: [.pre(.docsUpdate),
                                                       .pre(.dependenciesCompatibility([.cocoapods, .carthage, .spm(.all)]))],
                                             add: ["README.md",
                                                   "YourLibraryName.podspec",
                                                   "CHANGELOG.md"],
                                             commitMessage: "Version \(Argument.version)",
                                             push: false))
```

Let's see how you can edit this by yourself to get the result you want.

## TapestryConfig

This currently only has one argument `relase`, more will be added here

## Release

The main component of the release process.

| Property        | Description           | Type  | Optional      |   Default   |
| ------------- |:-------------:| :-----:| :-----:| :-----:|
| actions      | Your custom release steps, more about how you can define them below (see `ReleaseAction`) | [ReleaseAction] | No | []
| add      | Glob of your files that you want to add to git before releasing a version   |   [String] |   Yes
| commitMessage |  Commit message - use `Argument.version` in your string which will translate to the version you are releasing   |  String |  No
| push      | This option determines if the changes are committed at the end | Bool | No | 

Running `tapestry release 0.0.1` also automatically tags the latest commit.

## ReleaseAction

This type lets you define the individual actions. 

| Case        | Description           | 
| ------------- |:-------------:|
| `pre(tool: String, arguments: [String] = [])`      | Runs before commiting and pushing. Runs the custom command from the root folder.
| `pre(_ predefinedAction: PredefinedAction)`      | Runs before commiting and pushing. Runs a `PredefinedAction`, more on that below.
| `post(tool: String, arguments: [String] = [])` |  Runs after commiting and pushing. Runs the custom command from the root folder.
| `post(_ predefinedAction: PredefinedAction)`       | Runs after commiting and pushing. Runs a `PredefinedAction`, more on that below.


## PredefinedAction

This is a set of predefined actions.

| Case        | Description           | 
| ------------- |:-------------:|
| `docsUpdate`      | Updates version in your `.podspec, README.md` and adds it in `CHANGELOG.md`
| `run(tool: String, arguments: [String])`     | You can run defined dev dependencies in `tapestries/Package.swift`
|  `dependenciesCompatibility([DependenciesManager])` |  Checks compatibility with given `DependenciesManager`s

Note that for `docsUpdate` your changelog must be in this format:
```
## Next

- your way of adding logs

## 1.0.0
....
```

Which will be changed to
```
## Next

## 1.0.1

- your way of adding logs

## 1.0.0
....
```

To change your version in `README.md` for different dependency managers, you should have this format:
```
github "Repo/YourLibrary" ~> 1.0.0
pod "YourLibrary", "~> 1.0.0"
.package(url: "https://github.com/Repo/YourLibrary.git", .upToNextMajor(from: "1.0.0"))
```

You can also try out the individual actions:
```bash
tapestry run action docs-update 1.0.0
tapestry run action compatibilty spm carthage cocoapods
```

## DependenciesManager

Let's you say what dependency managers you want to check compatibility for.

| Case        | Description           | 
| ------------- |:-------------:|
| `cocoapods`      | Runs compatibility check for [Cocoapods](https://github.com/CocoaPods/CocoaPods)
| `carthage`     | Runs compatibility check for [Carthage](Runs compatibility check for [Cocoapods](https://github.com/CocoaPods/CocoaPods))
| `spm(Platform)` |  Runs compatibility check for [SPM](https://github.com/apple/swift-package-manager) - define platform if you are using platform-specific libraries (eg `UIKit`)

### Run developer dependencies

If you want to use developer dependencies using [SPM](https://github.com/apple/swift-package-manager), but don't want the users to download them since they are not essential to the project, you can add them to `tapestries/Package.swift`.

If you then want to run it, just type:
```bash
tapestry run name-of-tool its-arguments
```
And it will run the tool you have previously defined - which means all the project's contributors can use the same version of your tooling!

### Inspiration and thanks

I'd like to thank [tuist](https://github.com/tuist/tuist) for inspiration and help in this project. This project was also inspired by [rocket](https://github.com/shibapm/Rocket)
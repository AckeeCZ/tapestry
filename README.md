# Tapestry
[![Build Status](https://travis-ci.com/AckeeCZ/tapestry.svg?branch=master)](https://travis-ci.com/AckeeCZ/tapestry)

## What's Tapestry 🤔

Tapestry helps you with **creating** and **managing** your Swift frameworks 💫

Do you want to easily create a Swift framework that supports Carthage, Cocoapods and Swift Package Manager? Well, look no further, `tapestry` shall help you with exactly that!

## Installation

### Using [Homebrew](https://brew.sh)

```bash
$ brew tap AckeeCZ/tapestry
$ brew install tapestry
$ tapestry
```


### Using Swift directly

```bash
$ git clone https://github.com/AckeeCZ/tapestry.git
$ cd tapestry
$ swift run tapestry
```

(currently necessary if you want to customize the template)

## Generating project

<img alt="Screenshot" src="Resources/tapestry.gif" width="700">


To generate your project, simply run: 
```bash
tapestry init --path TapestryProject
```

You can omit `--path` argument and it will generate your framework in the current directory.

It uses [tuist](https://github.com/tuist/tuist) and [SPM](https://github.com/apple/swift-package-manager) tools, so it's very easy to adjust it to your needs (no complicated template structure, all code is generated from **ground up**!)

You can change the generated files in `InitCommand` and your example project in `ExampleModelLoader`. In the future, I'd like to make this customization even easier, so watch this space 👀

### Generated project features

- [x] `CocoaPods`, `Carthage` and `Swift Package Manager` compatibility
- [x] `README.md` template
- [x] `travis` to automate your builds
- [x] `Library` support
- [x] `Executable` support for your CLI tools
- [ ] more and even more to come!

You can check out an example project that was generated with `tapestry` [here](https://github.com/fortmarek/TapestryDemo).

## New release

When you run 
```bash
tapestry release 1.0.0
```

It not only tags the latest commit, but also updates it in your `README.md` and `.podspec`.
For example `pod "MyNewProject", "~> 0.0.1` is changed to `pod "MyNewProject", "~> 1.0.0` 🚀


## Swift BluFi Library


## Requirements

- iOS 8.0+
- Xcode 8.0+
- Swift 4.0+

## Getting Started

## Usage

## Installation

The recommended approach to use _BluFi_ in your project is using the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation.

### CocoaPods

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```
Go to the directory of your Xcode project, and Create and Edit your Podfile and add _BluFi_:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
pod 'BluFi', '~> 1.0.0'
```

Install into your project:

``` bash
$ pod install
```

If CocoaPods did not find the `BluFi 1.0.0` dependency execute this command:

```bash
$ pod repo update
```

Open your project in Xcode from the .xcworkspace file (not the usual project file)

``` bash
$ open MyProject.xcworkspace
```

### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `BluFi` by adding the proper description to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .Package(url: "https://github.com/tuanpmt/BluFi.git")
    ]
)
```

Note that the [Swift Package Manager](https://swift.org/package-manager) is still in early design and development, for more information checkout its [GitHub Page](https://github.com/apple/swift-package-manager).

### Carthage
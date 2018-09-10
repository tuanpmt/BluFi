// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BluFi",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BluFi",
            targets: ["BluFi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/yannickl/AwaitKit.git", from: "5.0.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "3.1.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.11.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BluFi",
            dependencies: ["AwaitKit", "BigInt", "CryptoSwift"]),
        .testTarget(
            name: "BluFiTests",
            dependencies: ["BluFi"]),
    ]
)

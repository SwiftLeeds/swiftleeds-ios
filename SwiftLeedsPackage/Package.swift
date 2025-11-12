// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftLeedsPackage",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftLeedsCore",
            targets: ["SwiftLeedsCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/yazio/ReadabilityModifier.git", .upToNextMajor(from: "1.0.0")),
        .package(name: "CachedAsyncImage", url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftLeedsCore",
            dependencies: [
                "CachedAsyncImage",
                "ReadabilityModifier",
            ]
        ),
        .testTarget(
            name: "SwiftLeedsCoreTests",
            dependencies: [
                "SwiftLeedsCore"
            ]
        ),
    ],
    // Set to v5 to avoid strict concurrency checking in pre swift 6 code
    swiftLanguageModes: [
        .v5,
    ]
)

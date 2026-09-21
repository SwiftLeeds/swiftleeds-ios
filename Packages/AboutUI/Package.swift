// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AboutUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "AboutUI", targets: ["AboutUI"]),
    ],
    dependencies: [
        .package(path: "../../SwiftLeedsPackage"),
        .package(path: "../AboutFeature"),
        .package(path: "../NetworkKit"),
        .package(path: "../UIComponents"),
        // 2.1.2 declares visionOS under a tools version that predates it, so its
        // manifest fails to load and resolution stops before it reaches us.
        .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", exact: "2.1.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
        .package(url: "https://github.com/yazio/ReadabilityModifier", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AboutUI",
            dependencies: [
                .product(name: "AboutFeature", package: "AboutFeature"),
                .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DesignKit", package: "SwiftLeedsPackage"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                // ReadabilityModifier declares iOS only, so it fails to build for
                // macOS. Every view is inside `#if canImport(UIKit)`.
                .product(
                    name: "ReadabilityModifier",
                    package: "ReadabilityModifier",
                    condition: .when(platforms: [.iOS])
                ),
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
                .product(name: "UIComponents", package: "UIComponents"),
            ]
        ),
        .testTarget(
            name: "AboutUITests",
            dependencies: [
                "AboutUI",
                .product(name: "AboutFeature", package: "AboutFeature"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ]
        ),
        .testTarget(
            name: "AboutUISnapshotTests",
            dependencies: [
                "AboutUI",
                .product(name: "AboutFeature", package: "AboutFeature"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DesignKit", package: "SwiftLeedsPackage"),
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LocalUI",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "LocalUI", targets: ["LocalUI"]),
    ],
    dependencies: [
        .package(path: "../../SwiftLeedsPackage"),
        .package(path: "../LocalFeature"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
        .package(url: "https://github.com/yazio/ReadabilityModifier", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "LocalUI",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DesignKit", package: "SwiftLeedsPackage"),
                .product(name: "LocalFeature", package: "LocalFeature"),
                // ReadabilityModifier declares iOS only, so it fails to build for
                // macOS. Every source file is inside `#if canImport(UIKit)`.
                .product(
                    name: "ReadabilityModifier",
                    package: "ReadabilityModifier",
                    condition: .when(platforms: [.iOS])
                ),
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
            ]
        ),
        .testTarget(
            name: "LocalUISnapshotTests",
            dependencies: [
                "LocalUI",
                .product(name: "DesignKit", package: "SwiftLeedsPackage"),
                .product(name: "LocalFeature", package: "LocalFeature"),
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)

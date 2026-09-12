// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SponsorsUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "SponsorsUI", targets: ["SponsorsUI"]),
    ],
    dependencies: [
        .package(path: "../../SwiftLeedsPackage"),
        .package(path: "../SponsorsFeature"),
        .package(path: "../UIComponents"),
        // 2.1.2 declares visionOS under a tools version that predates it, so its
        // manifest fails to load and resolution stops before it reaches us.
        .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", exact: "2.1.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "SponsorsUI",
            dependencies: [
                .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DesignKit", package: "SwiftLeedsPackage"),
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
                .product(name: "SponsorsFeature", package: "SponsorsFeature"),
                .product(name: "UIComponents", package: "UIComponents"),
            ]
        ),
        .testTarget(
            name: "SponsorsUISnapshotTests",
            dependencies: [
                "SponsorsUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "SponsorsFeature", package: "SponsorsFeature"),
            ]
        ),
    ]
)

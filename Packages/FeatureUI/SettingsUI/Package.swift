// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SettingsUI",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "SettingsUI", targets: ["SettingsUI"])
    ],
    dependencies: [
        .package(path: "../../Kit/NetworkKit"),
        .package(path: "../../DesignSystem/UITheme"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.10.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "SettingsUI",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Sharing", package: "swift-sharing"),
                .product(name: "UITheme", package: "UITheme"),
            ],
        ),
        .testTarget(
            name: "SettingsUITests",
            dependencies: [
                "SettingsUI",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "Sharing", package: "swift-sharing"),
            ],
        ),
        .testTarget(
            name: "SettingsUISnapshotTests",
            dependencies: [
                "SettingsUI",
                .product(name: "Sharing", package: "swift-sharing"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "UITheme", package: "UITheme"),
            ],
        ),
    ],
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "UIComponents", targets: ["UIComponents"]),
    ],
    dependencies: [
        .package(path: "../../SwiftLeedsPackage"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: [
                .product(name: "DesignKit", package: "SwiftLeedsPackage"),
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
            ]
        ),
        // Separate so CI can build and run the snapshot tests without compiling
        // anything else. The `UIComponentsSnapshotTests` scheme is what makes
        // that possible, and the name of this target is how CI finds it.
        .testTarget(
            name: "UIComponentsSnapshotTests",
            dependencies: [
                "UIComponents",
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)

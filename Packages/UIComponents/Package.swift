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

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "UIDesign",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "UIDesign", targets: ["UIDesign"]),
    ],
    dependencies: [
        .package(path: "../../SwiftLeedsPackage"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "UIDesign",
            dependencies: [
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
            ]
        ),
        // The name ends in SnapshotTests because that is how CI finds it.
        .testTarget(
            name: "UIDesignSnapshotTests",
            dependencies: [
                "UIDesign",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)

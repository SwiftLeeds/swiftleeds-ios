// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "UIDesign",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "UIDesign", targets: ["UIDesign"])
    ],
    dependencies: [
        .package(path: "../../../SwiftLeedsPackage"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols", from: "7.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "UIDesign",
            dependencies: [
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "UIAssets", package: "SwiftLeedsPackage"),
            ],
            resources: [.process("Resources")],
        ),
        .testTarget(
            name: "UIDesignTests",
            dependencies: ["UIDesign"],
        ),
        .testTarget(
            name: "UIDesignSnapshotTests",
            dependencies: [
                "UIDesign",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
        ),
    ],
)

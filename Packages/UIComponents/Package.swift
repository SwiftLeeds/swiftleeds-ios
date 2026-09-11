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
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: [
                .product(name: "DesignKit", package: "SwiftLeedsPackage"),
                .product(name: "SharedAssets", package: "SwiftLeedsPackage"),
            ]
        ),
    ]
)

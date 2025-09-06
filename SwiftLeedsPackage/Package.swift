// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftLeedsPackage",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SwiftLeedsPackage",
            targets: ["SwiftLeedsPackage"]),
    ],
    targets: [
        .target(
            name: "SwiftLeedsPackage"),
        .testTarget(
            name: "SwiftLeedsPackageTests",
            dependencies: ["SwiftLeedsPackage"]
        ),
    ]
)

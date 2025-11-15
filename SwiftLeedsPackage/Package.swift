// swift-tools-version: 6.2

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

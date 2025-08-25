// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftLeedsPackage",
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

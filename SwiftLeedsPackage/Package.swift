// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftLeedsPackage",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SwiftLeeds",
            targets: ["SwiftLeedsCore"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftLeedsCore"
        ),
        .testTarget(
            name: "SwiftLeedsCoreTests",
            dependencies: ["SwiftLeedsCore"]
        ),
    ]
)

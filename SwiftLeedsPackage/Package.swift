// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftLeedsPackage",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SwiftLeeds",
            targets: [
                "SwiftLeedsCore",
            ]
        ),
    ],
    targets: [
        .target(
            name: "SwiftLeedsCore"
        ),
    ]
)

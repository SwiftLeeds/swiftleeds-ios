// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SLNetwork",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SLNetwork",
            targets: [
                "Network",
            ],
        ),
    ],
    targets: [
        .target(
            name: "Network",
        ),
    ],
)

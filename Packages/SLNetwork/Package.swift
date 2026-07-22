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
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Network",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
    ],
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LocalFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "LocalFeature", targets: ["LocalFeature"]),
    ],
    dependencies: [
        .package(path: "../NetworkKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "LocalFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ]
        ),
        .testTarget(
            name: "LocalFeatureTests",
            dependencies: [
                "LocalFeature",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ]
        ),
    ]
)

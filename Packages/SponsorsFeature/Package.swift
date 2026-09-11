// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SponsorsFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "SponsorsFeature", targets: ["SponsorsFeature"]),
    ],
    dependencies: [
        .package(path: "../LogKit"),
        .package(path: "../NetworkKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SponsorsFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ]
        ),
        .testTarget(
            name: "SponsorsFeatureTests",
            dependencies: [
                "SponsorsFeature",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ]
        ),
    ]
)

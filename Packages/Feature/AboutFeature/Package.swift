// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AboutFeature",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "AboutFeature", targets: ["AboutFeature"])
    ],
    dependencies: [
        .package(path: "../../Kit/NetworkKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AboutFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ],
        ),
        .testTarget(
            name: "AboutFeatureTests",
            dependencies: [
                "AboutFeature",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "NetworkKitTestSupport", package: "NetworkKit"),
            ],
        ),
    ],
)

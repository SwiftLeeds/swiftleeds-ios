// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AuthenticationUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "AuthenticationUI", targets: ["AuthenticationUI"]),
    ],
    dependencies: [
        .package(path: "../AuthenticationFeature"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "AuthenticationUI",
            dependencies: [
                "AuthenticationFeature",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "AuthenticationUITests",
            dependencies: [
                "AuthenticationUI",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)

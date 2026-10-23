// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AuthenticationUI",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "AuthenticationUI", targets: ["AuthenticationUI"])
    ],
    dependencies: [
        .package(path: "../../Feature/AuthenticationFeature"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "AuthenticationUI",
            dependencies: [
                .product(name: "AuthenticationApplication", package: "AuthenticationFeature"),
                .product(name: "AuthenticationDomain", package: "AuthenticationFeature"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .testTarget(
            name: "AuthenticationUITests",
            dependencies: [
                "AuthenticationUI",
                .product(name: "AuthenticationApplication", package: "AuthenticationFeature"),
                .product(name: "AuthenticationDomain", package: "AuthenticationFeature"),
                .product(name: "AuthenticationFeatureTestSupport", package: "AuthenticationFeature"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        // Separate so CI can build and run the snapshot tests without compiling
        // anything else. The `AuthenticationUISnapshotTests` scheme is what makes
        // that possible, and the name of this target is how CI finds it.
        .testTarget(
            name: "AuthenticationUISnapshotTests",
            dependencies: [
                "AuthenticationUI",
                .product(name: "AuthenticationDomain", package: "AuthenticationFeature"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
        ),
    ],
)

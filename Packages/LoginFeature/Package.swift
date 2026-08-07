// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "LoginFeature",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "LoginFeature",
            targets: ["LoginFeature"]
        ),
    ],
    dependencies: [
        // Internal
        .package(path: "../SLAuth"),
        // External
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "LoginFeature",
            dependencies: [
                // Internal
                .product(name: "AuthApplication", package: "SLAuth"),

                // External
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
    ],
)

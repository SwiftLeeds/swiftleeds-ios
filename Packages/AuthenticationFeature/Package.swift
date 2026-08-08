// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AuthenticationFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "AuthenticationFeature", targets: ["AuthenticationFeature"]),
    ],
    targets: [
        .target(name: "AuthenticationFeature"),
        .testTarget(
            name: "AuthenticationFeatureTests",
            dependencies: ["AuthenticationFeature"]
        ),
    ]
)

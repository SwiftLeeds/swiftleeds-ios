// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SLSecureStorage",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: [
                "SecureStorage",
            ],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SecureStorage",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
    ],
)

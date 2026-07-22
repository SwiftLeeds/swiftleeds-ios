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
    targets: [
        .target(
            name: "SecureStorage",
        ),

    ],
)

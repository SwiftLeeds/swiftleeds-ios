// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "NetworkKit", targets: ["NetworkKit"]),
    ],
    targets: [
        .target(name: "NetworkKit"),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                "NetworkKit",
            ]
        ),
    ]
)

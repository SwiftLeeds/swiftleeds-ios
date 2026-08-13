// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LogKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "LogKit", targets: ["LogKit"]),
    ],
    targets: [
        .target(name: "LogKit"),
        .testTarget(
            name: "LogKitTests",
            dependencies: ["LogKit"]
        ),
    ]
)

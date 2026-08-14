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
        .library(name: "LogKitUnified", targets: ["LogKitUnified"]),
    ],
    targets: [
        .target(name: "LogKit"),
        .target(
            name: "LogKitUnified",
            dependencies: ["LogKit"]
        ),
        .testTarget(
            name: "LogKitTests",
            dependencies: ["LogKit"]
        ),
        .testTarget(
            name: "LogKitUnifiedTests",
            dependencies: ["LogKitUnified"]
        ),
    ]
)

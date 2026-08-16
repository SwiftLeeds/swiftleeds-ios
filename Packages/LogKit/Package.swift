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
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "LogKit",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
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

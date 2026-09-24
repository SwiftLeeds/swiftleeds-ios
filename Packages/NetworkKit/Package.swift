// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "NetworkKit", targets: ["NetworkKit"]),
        .library(name: "NetworkKitTestSupport", targets: ["NetworkKitTestSupport"]),
    ],
    dependencies: [
        .package(path: "../LogKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
            ]
        ),
        .target(
            name: "NetworkKitTestSupport",
            dependencies: ["NetworkKit"]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                "NetworkKit",
                "NetworkKitTestSupport",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "LogKitTestSupport", package: "LogKit"),
            ]
        ),
    ]
)

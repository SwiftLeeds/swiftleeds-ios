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
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                "NetworkKit",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
            ]
        ),
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ScheduleFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "ScheduleFeature", targets: ["ScheduleFeature"]),
    ],
    dependencies: [
        .package(path: "../NetworkKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ScheduleFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ]
        ),
        .testTarget(
            name: "ScheduleFeatureTests",
            dependencies: [
                "ScheduleFeature",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ]
        ),
    ]
)

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ScheduleFeature",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "ScheduleDomain", targets: ["ScheduleDomain"]),
        .library(name: "ScheduleFeature", targets: ["ScheduleFeature"]),
        .library(name: "ScheduleInfrastructure", targets: ["ScheduleInfrastructure"]),
    ],
    dependencies: [
        .package(path: "../../Kit/NetworkKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ScheduleDomain",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
        ),
        .target(
            name: "ScheduleFeature",
            dependencies: [
                "ScheduleDomain",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .target(
            name: "ScheduleInfrastructure",
            dependencies: [
                "ScheduleDomain",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
            ],
        ),
        .testTarget(
            name: "ScheduleFeatureTests",
            dependencies: [
                "ScheduleDomain",
                "ScheduleFeature",
                "ScheduleInfrastructure",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "NetworkKitTestSupport", package: "NetworkKit"),
            ],
        ),
    ],
)

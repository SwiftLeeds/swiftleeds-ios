// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ScheduleFeature",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "ScheduleApplication", targets: ["ScheduleApplication"]),
        .library(name: "ScheduleDomain", targets: ["ScheduleDomain"]),
        .library(name: "ScheduleDomainTestSupport", targets: ["ScheduleDomainTestSupport"]),
        .library(name: "ScheduleInfrastructure", targets: ["ScheduleInfrastructure"]),
    ],
    dependencies: [
        .package(path: "../../Kit/NetworkKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ScheduleApplication",
            dependencies: [
                "ScheduleDomain",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .target(
            name: "ScheduleDomain",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
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
        .target(
            name: "ScheduleDomainTestSupport",
            dependencies: ["ScheduleDomain"],
        ),
        .testTarget(
            name: "ScheduleFeatureTests",
            dependencies: [
                "ScheduleApplication",
                "ScheduleDomain",
                "ScheduleDomainTestSupport",
                "ScheduleInfrastructure",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "NetworkKitTestSupport", package: "NetworkKit"),
            ],
        ),
    ],
)

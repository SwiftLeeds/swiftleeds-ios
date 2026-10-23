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
                .product(name: "NetworkKit", package: "NetworkKit"),
            ],
        ),
        .testTarget(
            name: "ScheduleFeatureTests",
            dependencies: [
                "ScheduleDomain",
                "ScheduleFeature",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "NetworkKitTestSupport", package: "NetworkKit"),
            ],
        ),
    ],
)

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ScheduleUI",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "ScheduleUI", targets: ["ScheduleUI"])
    ],
    dependencies: [
        .package(path: "../../../SwiftLeedsPackage"),
        .package(path: "../../Feature/ScheduleFeature"),
        .package(path: "../../DesignSystem/UIComponents"),
        // 2.1.2 declares visionOS under a tools version that predates it, so its
        // manifest fails to load and resolution stops before it reaches us.
        .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", exact: "2.1.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "ScheduleUI",
            dependencies: [
                .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "ScheduleApplication", package: "ScheduleFeature"),
                .product(name: "ScheduleDomain", package: "ScheduleFeature"),
                .product(name: "UIAssets", package: "SwiftLeedsPackage"),
                .product(name: "UIComponents", package: "UIComponents"),
            ],
        ),
        .testTarget(
            name: "ScheduleUISnapshotTests",
            dependencies: [
                "ScheduleUI",
                .product(name: "ScheduleDomain", package: "ScheduleFeature"),
                .product(name: "ScheduleDomainTestSupport", package: "ScheduleFeature"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "UIComponents", package: "UIComponents"),
            ],
        ),
    ],
)

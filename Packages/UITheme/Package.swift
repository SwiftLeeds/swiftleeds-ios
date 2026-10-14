// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "UITheme",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "UITheme", targets: ["UITheme"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.10.1"),
    ],
    targets: [
        .target(
            name: "UITheme",
            dependencies: [
                .product(name: "Sharing", package: "swift-sharing")
            ],
        ),
        .testTarget(
            name: "UIThemeTests",
            dependencies: [
                "UITheme",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
                .product(name: "Sharing", package: "swift-sharing"),
            ],
        ),
    ],
)

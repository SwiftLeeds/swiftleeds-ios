// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ColorTheme",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "ColorTheme", targets: ["ColorTheme"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.10.1"),
    ],
    targets: [
        .target(
            name: "ColorTheme",
            dependencies: [
                .product(name: "Sharing", package: "swift-sharing"),
            ]
        ),
        .testTarget(
            name: "ColorThemeTests",
            dependencies: [
                "ColorTheme",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "Sharing", package: "swift-sharing"),
            ]
        ),
    ]
)

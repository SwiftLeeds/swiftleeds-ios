// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SettingsUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "SettingsUI", targets: ["SettingsUI"]),
    ],
    dependencies: [
        .package(path: "../ColorTheme"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.10.1"),
    ],
    targets: [
        .target(
            name: "SettingsUI",
            dependencies: [
                .product(name: "ColorTheme", package: "ColorTheme"),
                .product(name: "Sharing", package: "swift-sharing"),
            ]
        ),
        .testTarget(
            name: "SettingsUITests",
            dependencies: [
                "SettingsUI",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "Sharing", package: "swift-sharing"),
            ]
        ),
    ],
    // Swift 6 mode rejects `SettingsViewModel` sending `self` into the icon change callback.
    swiftLanguageModes: [
        .v5,
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SettingsUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "SettingsUI", targets: ["SettingsUI"]),
    ],
    dependencies: [
        .package(path: "../ColorTheme"),
    ],
    targets: [
        .target(
            name: "SettingsUI",
            dependencies: [
                .product(name: "ColorTheme", package: "ColorTheme"),
            ]
        ),
    ],
    // Swift 6 mode rejects `SettingsViewModel` sending `self` into the icon change callback.
    swiftLanguageModes: [
        .v5,
    ]
)

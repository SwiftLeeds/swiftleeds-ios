// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftLeedsPackage",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SwiftLeeds",
            targets: [
                "SwiftLeedsCore",
            ]
        ),
        .library(
            name: "Networking",
            targets: [
                "Networking",
            ]
        ),
        .library(
            name: "DesignKit",
            targets: [
                "DesignKit"
            ]
        ),
        .library(
            name: "Settings",
            targets: [
                "Settings",
            ]
        ),
        .library(
            name: "SharedAssets",
            targets: [
                "SharedAssets",
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.0"),
    ],
    targets: [
        .target(
            name: "SwiftLeedsCore"
        ),
        .target(
            name: "Networking"
        ),
        .target(
            name: "DesignKit"
        ),
        .target(
            name: "Settings",
            dependencies: [
                "ColorTheme",
            ]
        ),
        .target(
            name: "ColorTheme"
        ),
        .target(
            name: "SharedAssets"
        ),
    ],
    // Set to v5 to avoid strict concurrency checking in pre swift 6 code
    swiftLanguageModes: [
        .v5,
    ]
)

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
        ),
        .library(
            name: "SharedViews",
            targets: [
                "SharedViews",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/shadone/SwiftGenPlugin", branch: "6.6.2+deriveddatafix"),
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
            name: "SharedAssets",
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
            ]
        ),
        .target(
            name: "SharedViews",
            dependencies: [
                "SharedAssets",
            ]
        ),
    ],
    // Set to v5 to avoid strict concurrency checking in pre swift 6 code
    swiftLanguageModes: [
        .v5,
    ]
)

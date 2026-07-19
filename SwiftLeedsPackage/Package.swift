// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftLeedsPackage",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "DesignKit",
            targets: [
                "DesignKit"
            ]
        ),
        .library(
            name: "FeatureLogin",
            targets: [
                "FeatureLogin",
            ]
        ),
        .library(
            name: "Networking",
            targets: [
                "Networking",
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
            name: "SwiftLeeds",
            targets: [
                "SwiftLeedsCore",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/shadone/SwiftGenPlugin", branch: "6.6.2+deriveddatafix"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ColorTheme"
        ),
        .target(
            name: "DesignKit"
        ),
        .target(
            name: "FeatureLogin",
            dependencies: [
                "Networking",
            ]
        ),
        .target(
            name: "Networking"
        ),
        .target(
            name: "Settings",
            dependencies: [
                "ColorTheme",
                "FeatureLogin",
            ]
        ),
        .target(
            name: "SharedAssets",
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
            ]
        ),
        .target(
            name: "SwiftLeedsCore"
        ),
    ],
    // Set to v5 to avoid strict concurrency checking in pre swift 6 code
    swiftLanguageModes: [
        .v5,
    ]
)

// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ColorTheme",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "ColorTheme", targets: ["ColorTheme"]),
    ],
    targets: [
        .target(name: "ColorTheme"),
        .testTarget(name: "ColorThemeTests", dependencies: ["ColorTheme"]),
    ],
    // Swift 6 mode rejects `ThemeManager.shared`, a static that is not `Sendable`.
    swiftLanguageModes: [
        .v5,
    ]
)

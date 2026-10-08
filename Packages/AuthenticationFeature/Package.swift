// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AuthenticationFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "AuthenticationFeature", targets: ["AuthenticationFeature"]),
        .library(name: "AuthenticationFeatureTestSupport", targets: ["AuthenticationFeatureTestSupport"]),
    ],
    dependencies: [
        .package(path: "../LogKit"),
        .package(path: "../NetworkKit"),
        .package(path: "../SecureStorageKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AuthenticationFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "SecureStorageKit", package: "SecureStorageKit"),
            ]
        ),
        .target(
            name: "AuthenticationFeatureTestSupport",
            dependencies: ["AuthenticationFeature"]
        ),
        .testTarget(
            name: "AuthenticationFeatureTests",
            dependencies: [
                "AuthenticationFeature",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "LogKitTestSupport", package: "LogKit"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "NetworkKitTestSupport", package: "NetworkKit"),
                .product(name: "SecureStorageKit", package: "SecureStorageKit"),
            ]
        ),
    ]
)

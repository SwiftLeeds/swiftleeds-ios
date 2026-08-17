// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AuthenticationFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "AuthenticationFeature", targets: ["AuthenticationFeature"]),
    ],
    dependencies: [
        .package(path: "../LogKit"),
        .package(path: "../SecureStorageKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AuthenticationFeature",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "SecureStorageKit", package: "SecureStorageKit"),
            ]
        ),
        .testTarget(
            name: "AuthenticationFeatureTests",
            dependencies: [
                "AuthenticationFeature",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "SecureStorageKit", package: "SecureStorageKit"),
            ]
        ),
    ]
)

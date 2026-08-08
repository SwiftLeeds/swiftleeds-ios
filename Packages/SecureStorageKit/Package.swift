// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorageKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "SecureStorageKit", targets: ["SecureStorageKit"]),
        .library(name: "SecureStorageKitKeychain", targets: ["SecureStorageKitKeychain"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SecureStorageKit",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "SecureStorageKitKeychain",
            dependencies: [
                "SecureStorageKit",
            ]
        ),
        .testTarget(
            name: "SecureStorageKitKeychainTests",
            dependencies: [
                "SecureStorageKit",
                "SecureStorageKitKeychain",
            ]
        ),
    ]
)

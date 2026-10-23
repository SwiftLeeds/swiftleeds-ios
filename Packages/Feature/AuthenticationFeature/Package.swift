// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AuthenticationFeature",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "AuthenticationDomain", targets: ["AuthenticationDomain"]),
        .library(name: "AuthenticationFeature", targets: ["AuthenticationFeature"]),
        .library(name: "AuthenticationFeatureTestSupport", targets: ["AuthenticationFeatureTestSupport"]),
        .library(name: "AuthenticationInfrastructure", targets: ["AuthenticationInfrastructure"]),
    ],
    dependencies: [
        .package(path: "../../Kit/LogKit"),
        .package(path: "../../Kit/NetworkKit"),
        .package(path: "../../Kit/SecureStorageKit"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AuthenticationDomain",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
        ),
        .target(
            name: "AuthenticationFeature",
            dependencies: [
                "AuthenticationDomain",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
            ],
        ),
        .target(
            name: "AuthenticationInfrastructure",
            dependencies: [
                "AuthenticationDomain",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "SecureStorageKit", package: "SecureStorageKit"),
            ],
        ),
        .target(
            name: "AuthenticationFeatureTestSupport",
            dependencies: ["AuthenticationDomain"],
        ),
        .testTarget(
            name: "AuthenticationFeatureTests",
            dependencies: [
                "AuthenticationDomain",
                "AuthenticationFeature",
                "AuthenticationInfrastructure",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "LogKit", package: "LogKit"),
                .product(name: "LogKitTestSupport", package: "LogKit"),
                .product(name: "NetworkKit", package: "NetworkKit"),
                .product(name: "NetworkKitTestSupport", package: "NetworkKit"),
                .product(name: "SecureStorageKit", package: "SecureStorageKit"),
            ],
        ),
    ],
)

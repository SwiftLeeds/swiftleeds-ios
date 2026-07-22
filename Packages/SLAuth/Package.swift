// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SLAuth",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SessionAccess",
            targets: [
                "SessionAccess",
            ],
        ),
        .library(
            name: "AuthUI",
            targets: [
                "AuthUI",
            ],
        ),
        .library(
            name: "AuthInfra",
            targets: [
                "AuthInfra",
            ],
        ),
    ],
    dependencies: [
        // Internal
        .package(path: "../SLNetwork"),
        .package(path: "../SLSecureStorage"),

        // External
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AuthUI",
            dependencies: [
                // Local
                "AuthApplication",

                // External
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .target(
            name: "AuthApplication",
            dependencies: [
                // Local
                "AuthDomain",
                "SessionAccess",

                // External
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .target(
            name: "AuthDomain",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .target(
            name: "AuthInfra",
            dependencies: [
                // Local
                "AuthDomain",
                "SessionAccess",

                // Internal
                .product(name: "SLNetwork", package: "SLNetwork"),
                .product(name: "SecureStorage", package: "SLSecureStorage"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
        .target(
            name: "SessionAccess",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
        ),
    ],
    swiftLanguageModes: [
        .v5,
    ],
)

// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "AuthenticationKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AuthenticationKit",
            targets: ["AuthenticationKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/iosdevbyul/TrisNetworkKit.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "AuthenticationKit",
            dependencies: [
                .product(
                    name: "NetworkKit",
                    package: "TrisNetworkKit"
                )
            ]
        ),
        .testTarget(
            name: "AuthenticationKitTests",
            dependencies: ["AuthenticationKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

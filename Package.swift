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
        // 여기에는 다음 단계에서 NetworkKit을 추가
    ],
    targets: [
        .target(
            name: "AuthenticationKit",
            dependencies: []
        ),
        .testTarget(
            name: "AuthenticationKitTests",
            dependencies: ["AuthenticationKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlgoKit",
    platforms: [
        .iOS(.v15),
        .watchOS(.v8),
        .macOS(.v11),
        .tvOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AlgoKit",
            targets: ["AlgoKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CorvidLabs/swift-algorand.git", from: "0.1.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "AlgoKit",
            dependencies: [
                .product(name: "Algorand", package: "swift-algorand")
            ]
        ),
        .testTarget(
            name: "AlgoKitTests",
            dependencies: ["AlgoKit"]
        )
    ]
)

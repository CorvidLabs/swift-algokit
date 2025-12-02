// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-algokit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AlgoKit",
            targets: ["AlgoKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CorvidLabs/swift-algorand.git", from: "0.2.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "AlgoKit",
            dependencies: [
                .product(name: "Algorand", package: "swift-algorand")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AlgoKitTests",
            dependencies: ["AlgoKit"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)

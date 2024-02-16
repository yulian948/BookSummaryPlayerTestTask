// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "BookSummaryPlayerFeature",
            targets: ["BookSummaryPlayerFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "1.6.0"))
    ],
    targets: [
        .target(
            name: "Resources",
            dependencies: [],
            resources: [.process("Assets.xcassets")]),
        .target(
            name: "Models",
            dependencies: []),
        .target(
            name: "Utils",
            dependencies: []),
        .target(
            name: "AudioPlayerClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .target(
            name: "CustomUIElements",
            dependencies: ["Utils"]),
        .target(
            name: "BookSummaryPlayerFeature",
            dependencies: ["Models", 
                           "CustomUIElements",
                           "Resources",
                           "AudioPlayerClient",
                           .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                          ],
            resources: [.process("Resources")])
        ]
)

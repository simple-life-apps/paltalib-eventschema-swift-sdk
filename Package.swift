// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PaltaEventSchemaSwiftSDK",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "PaltaAnalytics",
            targets: [
                "PaltaAnalytics"
            ]
        ),
        .library(
            name: "PaltaAnalyticsModel",
            targets: [
                "PaltaAnalyticsModel"
            ]
        )
    ],
    dependencies: [
         .package(url: "https://github.com/simple-life-apps/paltalib-swift-core.git", from: "3.2.2"),
         .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
         .package(url: "https://github.com/krzysztofzablocki/Difference.git", from: "1.0.2")
    ],
    targets: [
        .target(
            name: "PaltaAnalytics",
            dependencies: [
                .product(name: "PaltaCore", package: "paltalib-swift-core"),
                "PaltaAnalyticsWiring",
                "PaltaAnalyticsModel",
                "PaltaAnalyticsPrivateModel"
            ],
            path: "Sources/Analytics"
        ),
        .target(
            name: "PaltaAnalyticsWiring",
            dependencies: [],
            path: "Sources/AnalyticsWiring",
            publicHeadersPath: "Public"
        ),
        .target(
            name: "PaltaAnalyticsModel",
            dependencies: [],
            path: "Sources/AnalyticsModel"
        ),
        .target(
            name: "PaltaAnalyticsPrivateModel",
            dependencies: [.product(name: "SwiftProtobuf", package: "swift-protobuf")],
            path: "Sources/AnalyticsPrivateModel"
        ),
        .testTarget(
            name: "PaltaAnalyticsTests",
            dependencies: [
                "PaltaAnalytics",
                .product(name: "Difference", package: "difference")
            ],
            path: "Tests/Analytics"
        )
    ]
)

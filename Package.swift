// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "audioctl",
    dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "audioctl",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)

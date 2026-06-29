// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Sticker",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Sticker",
            targets: ["Sticker"]
        ),
    ],
    targets: [
        .target(name: "Sticker"),
    ]
)

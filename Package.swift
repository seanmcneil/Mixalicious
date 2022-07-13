// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Mixalicious",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "Mixalicious",
            targets: ["Mixalicious"]
        ),
    ],
    targets: [
        .target(
            name: "Mixalicious",
            dependencies: []
        ),
        .testTarget(
            name: "MixaliciousTests",
            dependencies: ["Mixalicious"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

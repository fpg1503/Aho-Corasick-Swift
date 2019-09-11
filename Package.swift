// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Aho-Corasick",
    products: [
        .library(
            name: "Aho-Corasick",
            targets: ["Aho-Corasick"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Aho-Corasick",
            dependencies: []),
        .testTarget(
            name: "Aho-CorasickTests",
            dependencies: ["Aho-Corasick"]),
    ]
)

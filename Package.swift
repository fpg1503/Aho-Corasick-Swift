// swift-tools-version:5.4.0
import PackageDescription

let package = Package(
    name: "Aho-Corasick-SPM",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "Aho-Corasick-SPM",
            targets: ["Aho-Corasick-SPM"]),
    ],
    dependencies: [
        // no dependencies
    ],
    targets: [
        .target(
            name: "Aho-Corasick-SPM",
            dependencies: []),
        .testTarget(
            name: "Aho-Corasick-SPM",
            dependencies: ["Aho-Corasick-SPM"]),
    ]
)

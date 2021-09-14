// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Aho-Corasick-SPM",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "Aho-Corasick-SPM",
            targets: ["Aho-Corasick-SPM"]
        ),
    ],
    targets: [
        .target(
            name: "Aho-Corasick-SPM",
            dependencies: []
        ),
    ]
)

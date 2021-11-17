// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Aho-Corasick-SPM",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "Aho-Corasick-Swift",
            targets: ["Aho-Corasick-Swift"]
        ),
    ],
    targets: [
        .target(
            name: "Aho-Corasick-Swift",
            path: "Source"
        ),
    ]
)

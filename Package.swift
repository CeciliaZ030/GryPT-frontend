// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "GryPT",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "GryPT", targets: ["GryPT"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GryPT",
            dependencies: [],
            path: "GryPT",
            exclude: ["Tests"]
        ),
        .testTarget(
            name: "GryPTTests",
            dependencies: ["GryPT"],
            path: "GryPT/Tests",
            exclude: ["UITests"]
        ),
        .testTarget(
            name: "GryPTUITests",
            dependencies: ["GryPT"],
            path: "GryPT/Tests/UITests"
        )
    ]
)

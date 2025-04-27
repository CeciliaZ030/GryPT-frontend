#!/bin/bash

# Create a Swift Package Manager package
cat > Package.swift << 'EOF'
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "GryPT",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "GryPT", targets: ["GryPT"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GryPT",
            dependencies: [],
            path: "GryPT"
        ),
    ]
)
EOF

# Create the directory structure expected by SPM
mkdir -p .build

# Generate Xcode project from SPM package
swift package generate-xcodeproj

echo "Xcode project has been generated. Open GryPT.xcodeproj to start working on your project."
echo "Note: You may need to set up the iOS deployment target in the project settings." 
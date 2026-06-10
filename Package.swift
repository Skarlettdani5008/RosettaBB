// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RosettaBB",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "RosettaBBCore"),
        .executableTarget(
            name: "RosettaBB",
            dependencies: ["RosettaBBCore"]
        ),
        .testTarget(
            name: "RosettaBBCoreTests",
            dependencies: ["RosettaBBCore"]
        ),
    ]
)

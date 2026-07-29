// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GhostPal",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "GhostPal",
            targets: ["GhostPal"]
        )
    ],
    targets: [
        .executableTarget(
            name: "GhostPal",
            path: "GhostPal",
            exclude: ["Info.plist"]
        )
    ]
)

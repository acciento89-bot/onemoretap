// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OneMoreTapCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "OneMoreTapCore", targets: ["OneMoreTapCore"])
    ],
    targets: [
        .target(
            name: "OneMoreTapCore",
            path: "OneMoreTap",
            exclude: ["Assets.xcassets", "ClassicGameModel.swift", "ClassicGameView.swift", "Haptics.swift", "Info.plist", "OneMoreTapApp.swift", "Shapes.swift", "StatsStore.swift"],
            sources: ["GameCore.swift"]
        ),
        .testTarget(
            name: "OneMoreTapCoreTests",
            dependencies: ["OneMoreTapCore"],
            path: "OneMoreTapTests",
            sources: ["GameCoreTests.swift"]
        )
    ]
)

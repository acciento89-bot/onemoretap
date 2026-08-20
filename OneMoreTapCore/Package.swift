// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "OneMoreTapCore",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(name: "OneMoreTapCore", targets: ["OneMoreTapCore"])
  ],
  targets: [
    .target(name: "OneMoreTapCore"),
    .testTarget(name: "OneMoreTapCoreTests", dependencies: ["OneMoreTapCore"]),
  ]
)

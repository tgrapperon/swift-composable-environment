// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "swift-composable-environment",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "ComposableEnvironment",
      targets: ["ComposableEnvironment"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.21.0"),
  ],
  targets: [
    .target(
      name: "ComposableEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "ComposableEnvironmentTests",
      dependencies: ["ComposableEnvironment"]
    ),
  ]
)

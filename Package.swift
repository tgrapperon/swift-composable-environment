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
    .library(
      name: "GlobalEnvironment",
      targets: ["GlobalEnvironment"]
    ),
    .library(
      name: "ComposableDependencies",
      targets: ["ComposableDependencies"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.21.0"),
  ],
  targets: [
    .target(
      name: "ComposableEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ComposableDependencies",
        "_DependencyAliases",
      ]
    ),
    .testTarget(
      name: "ComposableEnvironmentTests",
      dependencies: ["ComposableEnvironment"]
    ),
    .target(
      name: "ComposableDependencies",
      dependencies: [
        .target(name: "_Dependencies")
      ]
    ),
    .target(
      name: "_Dependencies",
      dependencies: []
    ),
    .target(
      name: "_DependencyAliases",
      dependencies: [
        "ComposableDependencies",
      ]
    ),
    .testTarget(
      name: "DependencyAliasesTests",
      dependencies: ["_DependencyAliases"]
    ),
    .target(
      name: "GlobalEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ComposableDependencies",
        "_DependencyAliases",
      ]
    ),
    .testTarget(
      name: "GlobalEnvironmentTests",
      dependencies: [
        "GlobalEnvironment",
      ]
    ),
  ]
)

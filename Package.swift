// swift-tools-version:5.3

import PackageDescription

/// Because some code is shared between `ComposableEnvironment` and `GlobalEnvironment`, and in
/// order to expose only the minimum API surface, the package is split in several targets.
///
/// The third product called `ComposableDependencies` can be used in case you want to define
/// dependencies in an environment-agnostic way. Such dependencies can then be imported and used by
/// `ComposableEnvironment` or `GlobalEnvironment`.
///
/// Targets with names starting with a underscore are used for implementation only and their types
/// exported on a case by case basis. They should not be imported as a whole without prefixing the
/// import with the `@_implementationOnly` keyword.

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
      name: "ComposableDependencies",
      targets: ["ComposableDependencies"]
    ),
    .library(
      name: "ComposableEnvironment",
      targets: ["ComposableEnvironment"]
    ),
    .library(
      name: "GlobalEnvironment",
      targets: ["GlobalEnvironment"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.21.0"),
  ],
  targets: [
    .target(
      name: "ComposableDependencies",
      dependencies: ["_Dependencies"]
    ),

    .target(
      name: "ComposableEnvironment",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ComposableDependencies",
        "_Dependencies",
        "_DependencyAliases",
      ]
    ),
    .testTarget(
      name: "ComposableEnvironmentTests",
      dependencies: ["ComposableEnvironment"]
    ),

    .target(name: "_Dependencies"),

    .target(
      name: "_DependencyAliases",
      dependencies: ["ComposableDependencies"]
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
        "_Dependencies",
        "_DependencyAliases",
      ]
    ),
    .testTarget(
      name: "GlobalEnvironmentTests",
      dependencies: ["GlobalEnvironment"]
    ),
  ]
)

// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "swift-composableEnvironment",
  products: [
    .library(
      name: "ComposableEnvironment",
      targets: ["ComposableEnvironment"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "ComposableEnvironment",
      dependencies: []),
    .testTarget(
      name: "ComposableEnvironmentTests",
      dependencies: ["ComposableEnvironment"]),
  ])

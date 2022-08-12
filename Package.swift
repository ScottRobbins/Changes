// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Changes",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .executable(name: "changes", targets: ["ChangesCLI"]),
    .library(name: "Changes", targets: ["Changes"]),
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.2"),
    .package(url: "https://github.com/mrackwitz/Version.git", from: "0.8.0"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
    .package(url: "https://github.com/apple/swift-format.git", branch: "release/5.6"),
  ],
  targets: [
    .target(
      name: "Changes",
      dependencies: [
        "Files",
        "Version",
        "Yams",
      ]
    ),
    .executableTarget(
      name: "ChangesCLI",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        "Files",
        "Version",
        "Yams",
      ]
    ),
    .testTarget(
      name: "ChangesCLITests",
      dependencies: ["ChangesCLI"]
    ),
    .testTarget(
      name: "ChangesTests",
      dependencies: ["Changes"]
    ),
  ]
)

// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Changes",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "Changes", targets: ["Changes"]),
    .executable(name: "changes", targets: ["ChangesCLI"])
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Files", .upToNextMajor(from: "4.0.0")),
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.0")),
    .package(url: "https://github.com/mrackwitz/Version.git", .upToNextMinor(from: "0.8.0")),
    .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "4.0.0")),
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
    .target(
      name: "ChangesCLI",
      dependencies: [
        "Files",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        "Version",
        "Yams",
      ]
    ),
    .testTarget(
      name: "ChangesTests",
      dependencies: ["Changes"]
    ),
  ]
)

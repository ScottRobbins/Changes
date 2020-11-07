// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Changes",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .executable(name: "changes", targets: ["ChangesCLI"])
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.1.0")),
    .package(url: "https://github.com/mrackwitz/Version.git", .exact("0.8.0")),
    .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
  ],
  targets: [
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
      name: "ChangesCLITests",
      dependencies: ["ChangesCLI"]
    ),
  ]
)

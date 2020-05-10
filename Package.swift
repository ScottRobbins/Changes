// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ChangelogManager",
  platforms: [
    .macOS(.v10_12)
  ],
  products: [
    .executable(name: "changelog", targets: ["ChangelogManager"])
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.5")),
    .package(url: "https://github.com/mrackwitz/Version.git", .exact("0.8.0")),
    .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.0"),
  ],
  targets: [
    .target(
      name: "ChangelogManager",
      dependencies: [
        "Files",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        "Version",
        "Yams",
      ]
    ),
    .testTarget(
      name: "ChangelogManagerTests",
      dependencies: ["ChangelogManager"]
    ),
  ]
)

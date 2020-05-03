// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ChangelogManager",
  products: [
    .executable(name: "changelog-manager", targets: ["ChangelogManager"])
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.5")),
    .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "ChangelogManager",
      dependencies: [
        "Files", .product(name: "ArgumentParser", package: "swift-argument-parser"), "Yams",
      ]
    ),
    .testTarget(
      name: "ChangelogManagerTests",
      dependencies: ["ChangelogManager"]
    ),
  ]
)

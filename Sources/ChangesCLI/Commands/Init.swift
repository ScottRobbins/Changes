import ArgumentParser
import Files
import Yams

struct Init: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "init",
    abstract: "Set up repository with a \(Self.configFileName) config file and folder structure."
  )

  private static let configFileName = ".changes.yml"

  func validate() throws {
    guard Folder.current.containsFile(named: Self.configFileName) == false else {
      throw ValidationError(".changes.yml already exists.")
    }
  }

  func run() throws {
    let config = ChangesConfig(files: [
      .init(
        identifier: "changelog",
        path: "./CHANGELOG.md",
        tags: ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security"],
        automaticallyRegenerate: true,
        footerText: nil
      )
    ])

    let encoder = YAMLEncoder()
    let fileString = try encoder.encode(config)
    try Folder.current.createFile(named: Self.configFileName).append(fileString)

    let changelogsFolder = try Folder.current.createSubfolderIfNeeded(
      withName: ".changes"
    )
    try changelogsFolder.createSubfolderIfNeeded(withName: "Unreleased")
    try changelogsFolder.createSubfolderIfNeeded(withName: "releases")
  }
}

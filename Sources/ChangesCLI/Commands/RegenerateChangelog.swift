import ArgumentParser
import Version

struct RegenerateChangelog: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "regenerate",
    abstract: "Regenerate all changelog files."
  )

  func run() throws {
    try ChangelogGenerator().regenerateChangelogs()
  }
}

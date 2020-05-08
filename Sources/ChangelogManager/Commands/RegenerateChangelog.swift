import ArgumentParser
import Version

struct RegenerateChangelog: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "regenerate",
    abstract: "Regenerates all changelog files"
  )

  func run() throws {
    try ChangelogGenerator().regenerateChangelogs()
  }
}

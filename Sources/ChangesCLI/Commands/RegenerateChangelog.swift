import ArgumentParser
import Version

struct RegenerateChangelog: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "regenerate",
    abstract: "Regenerate all changelog files."
  )

  func run() throws {
    let config = try ConfigurationLoader().load()
    try ChangelogGenerator().regenerateChangelogs(config: config)
  }
}

import ArgumentParser

struct ChangelogManager: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: nil,
    abstract: "A utility and framework for managing and generating changelogs",
    version: "0.0.1",
    subcommands: [Init.self, Add.self, RegenerateChangelog.self, Release.self]
  )
}

ChangelogManager.main()

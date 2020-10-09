import ArgumentParser

struct Changes: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: nil,
    abstract: "A utility and framework for managing and generating changelogs",
    version: "0.1.0",
    subcommands: [Init.self, Add.self, Regenerate.self, Release.self, Releases.self]
  )
}

Changes.main()

import ArgumentParser

struct Changes: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: nil,
    abstract: "A utility and framework for managing and generating changelogs",
    version: "0.1.0",
    subcommands: [
      Init.self, Add.self, Regenerate.self, ReleaseCommand.self, Releases.self, Entries.self,
    ]
  )
}

Changes.main()

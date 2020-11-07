import ArgumentParser
import Version

struct Regenerate: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "regenerate",
    abstract: "Regenerate files."
  )

  @Argument(
    help: .init(
      "Specify the files you would like to regenerate."
    )
  )
  var identifiers: [String] = []

  func validate() throws {
    let loadedConfig = try ConfigurationLoader().load()
    for identifier in identifiers {
      guard loadedConfig.config.files.map(\.identifier).contains(identifier) else {
        throw ValidationError(
          #""\#(identifier)" is not a valid identifier for a file defined in the config."#
        )
      }
    }
  }

  func run() throws {
    if identifiers.isEmpty {
      try ChangelogGenerator().regenerateAutomaticallyRegeneratableFiles()
    }
    else {
      try ChangelogGenerator().regenerateFiles(identifiers: identifiers)
    }
  }
}

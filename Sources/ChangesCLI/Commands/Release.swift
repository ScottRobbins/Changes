import ArgumentParser
import Version

struct Release: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "release",
    abstract: "Create a release."
  )

  @Argument(
    help: .init(
      "Specify the version number for this release."
    )
  )
  var version: Version?

  func run() throws {
    let config = try ConfigurationLoader().load()
    let version = self.version ?? getVersion()
    try ReleaseCreator().createRelease(version: version)
    try ChangelogGenerator().regenerateChangelogs(config: config)
  }

  private func getVersion() -> Version {
    while true {
      print("Enter the version for this release:", terminator: " ")
      let readVersion = (readLine() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
      if let version = try? Version(readVersion) {
        return version
      }
      else if readVersion.isEmpty {
        print("Please enter a version number.")
      }
      else {
        print("\(readVersion) is not a valid version number.")
      }
    }
  }
}

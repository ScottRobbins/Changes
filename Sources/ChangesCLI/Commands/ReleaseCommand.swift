import ArgumentParser
import Version

struct ReleaseCommand: ParsableCommand {
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
    let version = self.version ?? getVersion()
    try ReleaseCreator().createRelease(version: version)
  }

  private func getVersion() -> Version {
    while true {
      print("Enter the version for this release:", terminator: " ")
      let readVersion = (readLine() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
      if let version = try? Version(readVersion) {
        return version
      } else if readVersion.isEmpty {
        print("Please enter a version number.")
      } else {
        print("\(readVersion) is not a valid version number.")
      }
    }
  }
}

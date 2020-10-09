import ArgumentParser
import Version

// Want to make sure the help mentions the magic keywords you can use

struct Releases: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "releases",
    abstract: "Query for releases."
  )

  @Argument(
    help: .init(
      "Specify the versions to query for."
    )
  )
  var versions: [String]

  @Option(
    name: .shortAndLong,
    help: .init(
      "Start of version range to query for."
    )
  )
  var start: String?

  @Option(
    name: .shortAndLong,
    help: .init(
      "End of version range to query for."
    )
  )
  var end: String?

  private let unreleased = "unreleased"
  private let latest = "latest"

  func validate() throws {
    // Check to make sure that any versions listed are either a valid release or magic keyword
  }

  func run() throws {

  }
}

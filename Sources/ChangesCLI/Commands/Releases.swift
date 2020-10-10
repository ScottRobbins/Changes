import ArgumentParser
import Foundation
import Version

// Want to make sure the help mentions the magic keywords you can use

struct ReleaseQueryResponse: Codable {
  let releases: [ReleaseQueryItem]
}

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

  func validate() throws {
    for version in versions {
      guard version == "latest" || Version.valid(string: version) else {
        throw ValidationError(#""\#(version)" is not a valid version"#)
      }
    }

    guard versions.isEmpty || (start == nil && end == nil) else {
      throw ValidationError("Cannot specify specific versions along with a version range")
    }
  }

  func run() throws {
    let releaseQuerier = ReleaseQuerier()
    let queriedReleases: [ReleaseQueryItem]
    if !versions.isEmpty {
      let explicitVersions = try versions.filter { $0 != "latest" }.map { try Version($0) }
      let includeLatest = versions.contains("latest")
      queriedReleases = try releaseQuerier.query(
        versions: explicitVersions,
        includeLatest: includeLatest
      )
    } else if let start = start, let end = end {
      let startVersion = try Version(start)
      let endVersion = try Version(end)

      queriedReleases = try releaseQuerier.query(versions: startVersion...endVersion)
    } else if let start = start {
      let startVersion = try Version(start)
      queriedReleases = try releaseQuerier.query(versions: startVersion...)
    } else if let end = end {
      let endVersion = try Version(end)
      queriedReleases = try releaseQuerier.query(versions: ...endVersion)
    } else {
      queriedReleases = try releaseQuerier.queryAll()
    }

    let response = ReleaseQueryResponse(releases: queriedReleases)
    let encoder = JSONEncoder()
    let releasesJsonData = try encoder.encode(response)
    guard let responseJsonString = String(data: releasesJsonData, encoding: .utf8) else {
      throw ChangesError("Could not create json string from response.")
    }
    print(responseJsonString)
  }
}

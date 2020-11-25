import ArgumentParser
import Foundation
import Version

// Want to make sure the help mentions the magic keywords you can use

struct EntriesQueryResponse: Codable {
  let entries: [ChangesQueryItem]
}

struct Entries: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "entries",
    abstract: "Query for entries."
  )

  @Option(
    name: .shortAndLong,
    help: .init(
      "Specify the versions to query for."
    )
  )
  var versions: [String] = []

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
      guard version == "latest" || version == "unreleased" || Version.valid(string: version) else {
        throw ValidationError(#""\#(version)" is not a valid version"#)
      }

      guard
        version == "latest" || version == "unreleased" || (try! Version(version)).prerelease == nil
      else {
        throw ValidationError("Cannot specify prerelease version")
      }
    }

    if let start = start, start != "latest" {
      guard let version = try? Version(start) else {
        throw ValidationError(#""\#(start)" is not a valid version"#)
      }

      guard version.prerelease == nil else {
        throw ValidationError("Cannot specify prerelease version")
      }
    }

    if let end = end, end != "latest" {
      guard let version = try? Version(end) else {
        throw ValidationError(#""\#(end)" is not a valid version"#)
      }

      guard version.prerelease == nil else {
        throw ValidationError("Cannot specify prerelease version")
      }
    }

    guard versions.isEmpty || (start == nil && end == nil) else {
      throw ValidationError("Cannot specify specific versions along with a version range")
    }
  }

  func run() throws {
    let changesQuerier = ChangesQuerier()
    let queriedChanges: [ChangesQueryItem]
    if !versions.isEmpty {
      let explicitVersions = try versions.filter { $0 != "latest" && $0 != "unreleased" }.map {
        try Version($0)
      }
      let includeLatest = versions.contains("latest")
      let includeUnreleased = versions.contains("unreleased")
      queriedChanges = try changesQuerier.query(
        versions: explicitVersions,
        includeLatest: includeLatest,
        includeUnreleased: includeUnreleased
      )
    }
    else if let start = start, let end = end {
      let startVersion = try Version(start)
      if end == "latest" {
        queriedChanges = try changesQuerier.queryUpToLatest(start: startVersion)
      }
      else {
        let endVersion = try Version(end)
        queriedChanges = try changesQuerier.query(versions: startVersion...endVersion)
      }
    }
    else if let start = start {
      if start == "latest" {
        queriedChanges = try changesQuerier.queryIncludingUnreleasedStartingAtLatest()
      } else {
        let startVersion = try Version(start)
        queriedChanges = try changesQuerier.queryIncludingUnreleased(start: startVersion)
      }
    }
    else if let end = end {
      if end == "latest" {
        queriedChanges = try changesQuerier.queryUpToLatest()
      }
      else {
        let endVersion = try Version(end)
        queriedChanges = try changesQuerier.query(versions: ...endVersion)
      }
    }
    else {
      queriedChanges = try changesQuerier.queryAll()
    }

    let response = EntriesQueryResponse(entries: queriedChanges)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let releasesJsonData = try encoder.encode(response)
    guard let responseJsonString = String(data: releasesJsonData, encoding: .utf8) else {
      throw ChangesError("Could not create json string from response.")
    }
    print(responseJsonString)
  }
}

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
      "Specify the releases to query for."
    )
  )
  var releases: [String] = []

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

  @Option(
    name: .shortAndLong,
    parsing: .upToNextOption,
    help: .init(
      "Specify one or more tags to query for."
    )
  )
  var tags: [String] = []

  func validate() throws {
    for release in releases {
      guard release == "latest" || release == "unreleased" || Version.valid(string: release) else {
        throw ValidationError(#""\#(release)" is not a valid version"#)
      }

      guard
        release == "latest" || release == "unreleased" || (try! Version(release)).prerelease == nil
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

    guard releases.isEmpty || (start == nil && end == nil) else {
      throw ValidationError("Cannot specify specific versions along with a version range")
    }
  }

  func run() throws {
    let tags = self.tags.isEmpty ? nil : Set(self.tags)
    let changesQuerier = ChangesQuerier()
    let queriedChanges: [ChangesQueryItem]
    if !releases.isEmpty {
      let explicitVersions = try releases.filter { $0 != "latest" && $0 != "unreleased" }.map {
        try Version($0)
      }
      let includeLatest = releases.contains("latest")
      let includeUnreleased = releases.contains("unreleased")
      queriedChanges = try changesQuerier.query(
        versions: explicitVersions,
        includeLatest: includeLatest,
        includeUnreleased: includeUnreleased,
        tags: tags
      )
    } else if let start = start, let end = end {
      let startVersion = try Version(start)
      if end == "latest" {
        queriedChanges = try changesQuerier.queryUpToLatest(start: startVersion, tags: tags)
      } else {
        let endVersion = try Version(end)
        queriedChanges = try changesQuerier.query(versions: startVersion...endVersion, tags: tags)
      }
    } else if let start = start {
      if start == "latest" {
        queriedChanges = try changesQuerier.queryIncludingUnreleasedStartingAtLatest(tags: tags)
      } else {
        let startVersion = try Version(start)
        queriedChanges = try changesQuerier.queryIncludingUnreleased(
          start: startVersion,
          tags: tags
        )
      }
    } else if let end = end {
      if end == "latest" {
        queriedChanges = try changesQuerier.queryUpToLatest(tags: tags)
      } else {
        let endVersion = try Version(end)
        queriedChanges = try changesQuerier.query(versions: ...endVersion, tags: tags)
      }
    } else {
      queriedChanges = try changesQuerier.queryAll(tags: tags)
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

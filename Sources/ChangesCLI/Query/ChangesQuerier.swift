import Files
import Foundation
import Version

struct ChangesQuerier {
  private let decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  func queryAllByRelease() throws -> ReleaseAndUnreleasedEntries {
    let loadedConfig = try ConfigurationLoader().load()
    guard let workingFolder = try File(path: loadedConfig.path).parent else {
      throw ChangesError("Could not find folder of changes config.")
    }

    let _releaseEntries = try releaseEntries(workingFolder: workingFolder)
    let _unreleasedEntries = try unreleasedEntries(workingFolder: workingFolder)
    return ChangesQuerier.ReleaseAndUnreleasedEntries(
      unreleasedEntries: _unreleasedEntries,
      releaseEntries: _releaseEntries
    )
  }

  private func releaseEntries(workingFolder: Folder) throws -> [ReleaseEntry] {
    let releaseFolders = try workingFolder.createSubfolderIfNeeded(
      at: ".changes/releases"
    ).subfolders
    return try ConcurrentAccumulation.reduce(
      Array(releaseFolders)
    ) { (releaseFolder, container) in
      let releaseInfo = try self.getReleaseInfo(for: releaseFolder)
      let prereleaseEntries: [PrereleaseEntry] =
        try releaseFolder
        .createSubfolderIfNeeded(withName: "prereleases")
        .subfolders
        .map {
          let prereleaseInfo = try self.getReleaseInfo(for: $0)
          let prereleaseEntries = try self.changelogEntries(releaseFolder: $0)
          return PrereleaseEntry(
            version: prereleaseInfo.version,
            createdAtDate: prereleaseInfo.createdAtDate,
            entries: prereleaseEntries
          )
        }
        .sorted { $0.version < $1.version }

      container.add(
        .init(
          version: releaseInfo.version,
          createdAtDate: releaseInfo.createdAtDate,
          entries: try self.changelogEntries(releaseFolder: releaseFolder),
          prereleases: prereleaseEntries
        )
      )
    }
  }

  private func unreleasedEntries(workingFolder: Folder) throws -> [ChangelogEntry] {
    let unreleasedFolder = try workingFolder.createSubfolderIfNeeded(
      at: ".changes/unreleased"
    )
    return try changelogEntries(releaseFolder: unreleasedFolder)
  }

  private func getReleaseInfo(for folder: Folder) throws -> ReleaseInfo {
    let releaseInfo = try folder.file(named: "info.json").read()
    return try decoder.decode(ReleaseInfo.self, from: releaseInfo)
  }

  private func changelogEntries(releaseFolder: Folder) throws -> [ChangelogEntry] {
    return try releaseFolder.createSubfolderIfNeeded(withName: "entries").files.map { file in
      let file = try file.read()
      return try decoder.decode(ChangelogEntry.self, from: file)
    }.sorted {
      $0.createdAtDate < $1.createdAtDate
    }
  }
}

extension ChangesQuerier {
  struct ReleaseAndUnreleasedEntries {
    let unreleasedEntries: [ChangelogEntry]
    let releaseEntries: [ReleaseEntry]
  }

  struct ReleaseEntry {
    let version: Version
    let createdAtDate: Date
    let entries: [ChangelogEntry]
    let prereleases: [PrereleaseEntry]
  }

  // Change it to actually set prerelease entries and not put all of those in the regular entries
  struct PrereleaseEntry {
    let version: Version
    let createdAtDate: Date
    let entries: [ChangelogEntry]
  }
}

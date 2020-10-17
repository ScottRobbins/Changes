import Files
import Foundation
import Version
import Yams

struct ChangesFetcher {
  private let decoder = YAMLDecoder()

  func fetch() throws -> ChangesFetcher.ReleaseAndUnreleasedEntries {
    let loadedConfig = try ConfigurationLoader().load()
    guard let workingFolder = try File(path: loadedConfig.path).parent else {
      throw ChangesError("Could not find folder of changes config.")
    }

    let _releaseEntries = try releaseEntries(workingFolder: workingFolder)
    let _unreleasedEntries = try unreleasedEntries(workingFolder: workingFolder)
    return ChangesFetcher.ReleaseAndUnreleasedEntries(
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
      let preReleaseFolders =
        try releaseFolder
        .createSubfolderIfNeeded(withName: "prereleases")
        .subfolders
        .map {
          (version: try self.getReleaseInfo(for: $0).version, folder: $0)
        }
        .sorted {
          $0.version < $1.version
        }
        .map(\.folder)

      let releaseFolders = preReleaseFolders + [releaseFolder]
      let entries = try changelogEntries(releaseFolders: releaseFolders)
      container.add(
        .init(
          version: releaseInfo.version,
          createdAtDate: releaseInfo.createdAtDate,
          entries: entries
        )
      )
    }
  }

  private func unreleasedEntries(workingFolder: Folder) throws -> [ChangelogEntry] {
    let unreleasedFolder = try workingFolder.createSubfolderIfNeeded(
      at: ".changes/unreleased/entries"
    )
    return try changelogEntries(entriesFolder: unreleasedFolder)
  }

  private func getReleaseInfo(for folder: Folder) throws -> ReleaseInfo {
    let releaseInfoString = try folder.file(named: "info.yml").readAsString()
    return try decoder.decode(ReleaseInfo.self, from: releaseInfoString)
  }

  private func changelogEntries(releaseFolders: [Folder]) throws -> [ChangelogEntry] {
    try releaseFolders.flatMap {
      try self.changelogEntries(
        entriesFolder: $0.createSubfolderIfNeeded(at: "entries")
      ).sorted {
        $0.createdAtDate < $1.createdAtDate
      }
    }
  }

  private func changelogEntries(entriesFolder: Folder) throws -> [ChangelogEntry] {
    return try entriesFolder.files.map { file in
      let fileString = try file.readAsString()
      return try decoder.decode(ChangelogEntry.self, from: fileString)
    }
  }
}

extension ChangesFetcher {
  struct ReleaseAndUnreleasedEntries {
    let unreleasedEntries: [ChangelogEntry]
    let releaseEntries: [ReleaseEntry]
  }

  struct ReleaseEntry {
    let version: Version
    let createdAtDate: Date
    let entries: [ChangelogEntry]
  }
}

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

  func queryAll() throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    let unreleasedQueryItems = changes.unreleasedEntries.map { changesQueryItem(from: $0) }
    let releaseQueryItems = changes.releaseEntries.flatMap { changesQueryItems(from: $0) }

    return unreleasedQueryItems + releaseQueryItems
  }

  func query(
    versions: [Version],
    includeLatest: Bool,
    includeUnreleased: Bool
  ) throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    let explicitChangesQueryItems = try explicitReleaseChangesQueryItems(
      changes: changes.releaseEntries,
      versions: versions
    )

    let latestChangesQueryItems: [ChangesQueryItem]
    if includeLatest {
      latestChangesQueryItems =
        latestReleaseEntry(releaseEntries: changes.releaseEntries).map {
          changesQueryItems(from: $0)
        } ?? []
    }
    else {
      latestChangesQueryItems = []
    }

    let unreleasedChangesQueryItems =
      includeUnreleased ? changes.unreleasedEntries.map { changesQueryItem(from: $0) } : []

    return unreleasedChangesQueryItems + latestChangesQueryItems + explicitChangesQueryItems
  }

  func query(versions versionRange: ClosedRange<Version>) throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    return changes.releaseEntries.filter { versionRange.contains($0.version) }.flatMap {
      changesQueryItems(from: $0)
    }
  }

  func query(versions versionRange: Range<Version>) throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    return changes.releaseEntries.filter { versionRange.contains($0.version) }.flatMap {
      changesQueryItems(from: $0)
    }
  }

  func query(versions versionRange: PartialRangeFrom<Version>) throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    return changes.releaseEntries.filter { versionRange.contains($0.version) }.flatMap {
      changesQueryItems(from: $0)
    }
  }

  func query(versions versionRange: PartialRangeUpTo<Version>) throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    return changes.releaseEntries.filter { versionRange.contains($0.version) }.flatMap {
      changesQueryItems(from: $0)
    }
  }

  func query(versions versionRange: PartialRangeThrough<Version>) throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    return changes.releaseEntries.filter { versionRange.contains($0.version) }.flatMap {
      changesQueryItems(from: $0)
    }
  }

  func queryUpToLatest() throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    return changes.releaseEntries.flatMap {
      changesQueryItems(from: $0)
    }
  }

  func queryUpToLatest(start startVersion: Version) throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    return changes.releaseEntries.filter { (startVersion...).contains($0.version) }.flatMap {
      changesQueryItems(from: $0)
    }
  }

  func queryIncludingUnreleasedStartingAtLatest() throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    let unreleasedQueryItems = changes.unreleasedEntries.map { changesQueryItem(from: $0) }
    let releaseQueryItems =
      latestReleaseEntry(releaseEntries: changes.releaseEntries).map { changesQueryItems(from: $0) }
      ?? []

    return unreleasedQueryItems + releaseQueryItems
  }

  func queryIncludingUnreleased(start startVersion: Version) throws -> [ChangesQueryItem] {
    let changes = try queryAllByRelease()
    let unreleasedQueryItems = changes.unreleasedEntries.map { changesQueryItem(from: $0) }
    let releaseQueryItems = changes.releaseEntries.filter { (startVersion...).contains($0.version) }
      .flatMap {
        changesQueryItems(from: $0)
      }

    return unreleasedQueryItems + releaseQueryItems
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

  private func changesQueryItem(
    from entry: ChangelogEntry,
    release: String? = nil,
    prerelease: String? = nil
  ) -> ChangesQueryItem {
    ChangesQueryItem(
      tags: entry.tags,
      description: entry.description,
      createdAtDate: entry.createdAtDate,
      release: release,
      prerelease: prerelease
    )
  }

  private func explicitReleaseChangesQueryItems(
    changes: [ReleaseEntry],
    versions: [Version]
  ) throws -> [ChangesQueryItem] {
    try versions
      .map { realVersion -> ReleaseEntry in
        let _matchedRelease = changes.first { $0.version == realVersion }
        guard let matchedRelease = _matchedRelease else {
          throw ChangesError(#"Version "\#(realVersion)" was not found"#)
        }

        return matchedRelease
      }.flatMap {
        changesQueryItems(from: $0)
      }
  }

  private func latestReleaseEntry(releaseEntries: [ReleaseEntry]) -> ReleaseEntry? {
    releaseEntries.sorted { $0.version > $1.version }.first
  }

  private func changesQueryItems(from releaseEntry: ReleaseEntry) -> [ChangesQueryItem] {
    let release = releaseEntry.version.description
    let topLevelReleaseEntries = releaseEntry.entries.map {
      changesQueryItem(from: $0, release: release)
    }
    let prereleaseEntries = releaseEntry.prereleases.flatMap { prereleaseEntry in
      prereleaseEntry.entries.map {
        changesQueryItem(
          from: $0,
          release: release,
          prerelease: prereleaseEntry.version.description
        )
      }
    }

    return topLevelReleaseEntries + prereleaseEntries
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

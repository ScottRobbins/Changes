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
    var releaseEntries = [ReleaseEntry]()
    var error: Error?
    let queue = DispatchQueue(
      label: "com.swiftbuildtools.changes.thread-safe-array",
      qos: .userInitiated,
      attributes: .concurrent
    )
    let group = DispatchGroup()
    let releaseFolders = try workingFolder.createSubfolderIfNeeded(
      at: ".changes/releases"
    ).subfolders

    for releaseFolder in releaseFolders {
      DispatchQueue.global(qos: .userInitiated).async(group: group) {
        do {
          let releaseInfo = try self.getReleaseInfo(for: releaseFolder)
          let preReleaseFolders =
            try releaseFolder
            .subfolders
            .filter { $0.name != "entries" }
            .map {
              (version: try self.getReleaseInfo(for: $0).version, folder: $0)
            }
            .sorted {
              $0.version < $1.version
            }
            .map(\.folder)

          let entryFolders = preReleaseFolders + [releaseFolder]
          let entries = try entryFolders.flatMap {
            try self.changelogEntries(
              folder: $0.createSubfolderIfNeeded(at: "entries")
            ).sorted {
              $0.createdAtDate < $1.createdAtDate
            }
          }

          queue.sync(flags: .barrier) {
            releaseEntries.append(
              .init(
                version: releaseInfo.version,
                createdAtDate: releaseInfo.createdAtDate,
                entries: entries
              )
            )
          }
        }
        catch let e {
          queue.sync(flags: .barrier) {
            error = e
          }
        }
      }
    }

    group.wait()

    if let error = error {
      throw error
    }

    return releaseEntries
  }

  private func unreleasedEntries(workingFolder: Folder) throws -> [ChangelogEntry] {
    let unreleasedFolder = try workingFolder.createSubfolderIfNeeded(
      at: ".changes/Unreleased"
    )
    return try changelogEntries(folder: unreleasedFolder)
  }

  private func getReleaseInfo(for folder: Folder) throws -> ReleaseInfo {
    let releaseInfoString = try folder.file(named: "info.yml").readAsString()
    return try decoder.decode(ReleaseInfo.self, from: releaseInfoString)
  }

  private func changelogEntries(folder: Folder) throws -> [ChangelogEntry] {
    return try folder.files.map { file in
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

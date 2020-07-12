import ArgumentParser
import Files
import Foundation
import Version
import Yams

struct ChangelogGenerator {
  private struct ReleaseEntry {
    let version: Version
    let createdAtDate: Date
    let entries: [ChangelogEntry]
  }

  let dateFormatter = ISO8601DateFormatter()
  let decoder = YAMLDecoder()

  init() {
    dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
  }

  func regenerateFiles(identifiers: [String]) throws {
    let loadedConfig = try ConfigurationLoader().load()
    for identifier in identifiers {
      guard loadedConfig.config.files.map(\.identifier).contains(identifier) else {
        throw ChangesError(
          "\(identifier) is not a valid identifier for a file defined in the config."
        )
      }
    }

    let files = loadedConfig.config.files.filter { identifiers.contains($0.identifier) }
    try regenerateFiles(files, loadedConfig: loadedConfig)
  }

  func regenerateAutomaticallyRegeneratableFiles() throws {
    let loadedConfig = try ConfigurationLoader().load()

    let files = loadedConfig.config.files.filter(\.automaticallyRegenerate)
    try regenerateFiles(files, loadedConfig: loadedConfig)
  }

  private func regenerateFiles(
    _ files: [ChangesConfig.ChangelogFile],
    loadedConfig: LoadedChangesConfig
  ) throws {
    guard let workingFolder = try File(path: loadedConfig.path).parent else {
      throw ChangesError("Could not find folder of changes config.")
    }

    let releaseEntries = try getReleaseEntries(workingFolder: workingFolder)
    let sortedReleaseEntries = releaseEntries.sorted { $0.version > $1.version }
    let unreleasedEntries = try getUnreleasedEntries(workingFolder: workingFolder)

    for file in files {
      try writeToChangelog(
        unreleasedEntries: unreleasedEntries,
        releaseEntries: sortedReleaseEntries,
        file: file,
        workingFolder: workingFolder
      )
    }
  }

  private func getReleaseEntries(workingFolder: Folder) throws -> [ReleaseEntry] {
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
          let preReleaseFolders = try releaseFolder
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

  private func getReleaseInfo(for folder: Folder) throws -> ReleaseInfo {
    let releaseInfoString = try folder.file(named: "info.yml").readAsString()
    return try decoder.decode(ReleaseInfo.self, from: releaseInfoString)
  }

  private func getUnreleasedEntries(workingFolder: Folder) throws -> [ChangelogEntry] {
    let unreleasedFolder = try workingFolder.createSubfolderIfNeeded(
      at: ".changes/Unreleased"
    )
    return try changelogEntries(folder: unreleasedFolder).sorted {
      $0.createdAtDate < $1.createdAtDate
    }
  }

  private func changelogEntries(folder: Folder) throws -> [ChangelogEntry] {
    return try folder.files.map { file in
      let fileString = try file.readAsString()
      return try decoder.decode(ChangelogEntry.self, from: fileString)
    }
  }

  private func writeToChangelog(
    unreleasedEntries: [ChangelogEntry],
    releaseEntries: [ReleaseEntry],
    file: ChangesConfig.ChangelogFile,
    workingFolder: Folder
  ) throws {
    let unreleasedContentString = sectionString(
      name: "Unreleased",
      entries: unreleasedEntries,
      file: file
    )

    let releaseContentString = releaseEntries.map { releaseEntry in
      return sectionString(
        name: releaseEntry.version.description,
        date: releaseEntry.createdAtDate,
        entries: releaseEntry.entries,
        file: file
      )
    }.joined(separator: "\n\n\n")

    let footerString =
      file.footerText.flatMap {
        """
        ---
        \($0)
        """
      } ?? ""

    let contentString = [
      unreleasedContentString,
      releaseContentString.isEmpty ? nil : releaseContentString,
      footerString.isEmpty ? nil : footerString,
    ]
    .compactMap { $0 }
    .joined(separator: "\n\n\n")

    let changelogString =
      """
      # Changelog
      All notable changes to this project will be documented in this file.
      This file is auto-generated by Changes. Any modifications made to it will be overwritten.


      \(contentString)
      """.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"

    try workingFolder.createFileIfNeeded(at: file.path).write(changelogString)
  }

  private func sectionString(
    name: String,
    date: Date? = nil,
    entries: [ChangelogEntry],
    file: ChangesConfig.ChangelogFile
  ) -> String {
    let sectionNameString: String
    if let date = date {
      let dateString = dateFormatter.string(from: date)
      sectionNameString = "## [\(name)] - \(dateString)"
    }
    else {
      sectionNameString = "## [\(name)]"
    }
    if entries.isEmpty {
      return sectionNameString
    }

    let validEntries = entries.filter { !Set(file.tags).intersection($0.tags).isEmpty }
    let usedTags = validEntries.flatMap(\.tags).uniqueValues().sorted {
      if let index1 = file.tags.firstIndex(of: $0),
        let index2 = file.tags.firstIndex(of: $1)
      {
        return index1 < index2
      }
      else {
        return false
      }
    }

    let tagsString: String = usedTags.map { usedTag in
      let entriesString =
        validEntries
        .filter { $0.tags.contains(usedTag) }
        .map {
          "- \($0.description)"
        }.joined(separator: "\n")

      return """
        ### \(usedTag)
        \(entriesString)
        """
    }.joined(separator: "\n\n")

    return """
      \(sectionNameString)
      \(tagsString)
      """
  }
}

import ArgumentParser
import Files
import Foundation
import Version

struct ReleaseCreator {
  func createRelease(version: Version) throws {
    let loadedConfig = try ConfigurationLoader().load()
    guard let workingFolder = try File(path: loadedConfig.path).parent else {
      throw ChangesError("Could not find folder of changes config.")
    }

    let releaseFolder = try workingFolder.createSubfolderIfNeeded(
      at: ".changes/releases/\(version.release)"
    )
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    let releaseInfo = Release(version: version.release, createdAtDate: Date())
    let outputString = try encoder.encode(releaseInfo)
    try releaseFolder.createFileIfNeeded(at: "info.json").write(outputString)

    let entriesFolder: Folder
    if version.isPrerelease {
      guard
        !releaseFolder.containsSubfolder(
          at: "prereleases/\(version.droppingBuildMetadata.description)"
        )
      else {
        throw ValidationError("Release \(version.droppingBuildMetadata) already exists")
      }

      let preReleaseFolder = try releaseFolder.createSubfolderIfNeeded(
        at: "prereleases/\(version.droppingBuildMetadata.description)"
      )
      let preReleaseInfo = Release(
        version: version.droppingBuildMetadata,
        createdAtDate: Date()
      )
      let outputString = try encoder.encode(preReleaseInfo)
      try preReleaseFolder.createFile(named: "info.json").write(outputString)
      entriesFolder = try preReleaseFolder.createSubfolderIfNeeded(withName: "entries")
      try releaseFolder.createSubfolderIfNeeded(withName: "entries")
    } else {
      entriesFolder = try releaseFolder.createSubfolderIfNeeded(withName: "entries")
    }

    let entryFiles =
      Array(try workingFolder.subfolder(at: ".changes/unreleased/entries").files)
      + Array(try releaseFolder.subfolder(at: "entries").files)
    for entryFile in entryFiles {
      try entryFile.move(to: entriesFolder)
    }
  }
}

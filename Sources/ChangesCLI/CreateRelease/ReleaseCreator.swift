import ArgumentParser
import Files
import Foundation
import Version
import Yams

struct ReleaseCreator {
  func createRelease(version: Version) throws {
    let releaseFolder = try Folder.current.createSubfolderIfNeeded(
      at: ".changes/releases/\(version.release)"
    )
    let encoder = YAMLEncoder()
    let releaseInfo = ReleaseInfo(version: version.release, createdAtDate: Date())
    let outputString = try encoder.encode(releaseInfo)
    try releaseFolder.createFileIfNeeded(withName: "info.yml").write(outputString)

    let entriesFolder: Folder
    if version.isPrerelease {
      guard !releaseFolder.containsSubfolder(named: version.droppingBuildMetadata.description)
      else {
        throw ValidationError("Release \(version.droppingBuildMetadata) already exists")
      }

      let preReleaseFolder = try releaseFolder.createSubfolderIfNeeded(
        withName: version.droppingBuildMetadata.description
      )
      let preReleaseInfo = ReleaseInfo(
        version: version.droppingBuildMetadata,
        createdAtDate: Date()
      )
      let outputString = try encoder.encode(preReleaseInfo)
      try preReleaseFolder.createFile(named: "info.yml").write(outputString)
      entriesFolder = try preReleaseFolder.createSubfolderIfNeeded(withName: "entries")
      try releaseFolder.createSubfolderIfNeeded(withName: "entries")
    }
    else {
      entriesFolder = try releaseFolder.createSubfolderIfNeeded(withName: "entries")
    }

    let entryFiles =
      Array(try Folder.current.subfolder(at: ".changes/Unreleased").files)
      + Array(try releaseFolder.subfolder(at: "entries").files)
    for entryFile in entryFiles {
      try entryFile.move(to: entriesFolder)
    }
  }
}

import Files
import Foundation

struct FileSystem {
  func unreleased() throws -> UnreleasedFolder {
    let unreleasedFolder = try changesFolder().createSubfolderIfNeeded(withName: "unreleased")
    return UnreleasedFolder(folder: unreleasedFolder)
  }

  private func changesFolder() throws -> Folder {
    guard let workingFolder = try ConfigurationLoader().load().file.parent else {
      throw ChangesError("Could not find folder of changes config.")
    }

    return try workingFolder.createSubfolderIfNeeded(withName: ".changes")
  }
}

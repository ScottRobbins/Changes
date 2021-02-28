import Files
import Foundation

struct UnreleasedFolder {
  let folder: Folder

  func entries() throws -> EntriesFolder {
    return try EntriesFolder(folder: folder.createSubfolderIfNeeded(withName: "entries"))
  }
}

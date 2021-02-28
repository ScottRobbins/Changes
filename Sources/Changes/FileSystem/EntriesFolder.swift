import Files
import Foundation

struct EntriesFolder {
  let folder: Folder

  func files() throws -> [Changes.File] {
    Array(folder.files)
  }
}

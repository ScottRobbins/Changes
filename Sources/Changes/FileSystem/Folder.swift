import Files
import Foundation

protocol Folder {
  func getFiles() -> [File]
}

struct DefaultFolder: Folder {
  let folder: Files.Folder

  func getFiles() -> [File] {
    folder.files.map(DefaultFile.init)
  }
}

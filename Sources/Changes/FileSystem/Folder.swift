import Files
import Foundation

protocol Folder {
  func getFiles() -> [File]
  func createSubfolderIfNeeded(withName name: String) throws -> Folder
}

struct DefaultFolder: Folder {
  let folder: Files.Folder

  func getFiles() -> [File] {
    folder.files.map(DefaultFile.init)
  }

  func createSubfolderIfNeeded(withName name: String) throws -> Folder {
    let subfolder = try folder.createSubfolderIfNeeded(withName: name)
    return DefaultFolder(folder: subfolder)
  }
}

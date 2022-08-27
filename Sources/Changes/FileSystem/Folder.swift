import Files
import Foundation

protocol Folder {
  func getFiles() -> [File]
  func createSubfolderIfNeeded(withName name: String) throws -> Folder
  func file(named name: String) throws -> File
  func getSubfolders() -> [Folder]
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

  func file(named name: String) throws -> File {
    let _file = try folder.file(named: name)
    return DefaultFile(file: _file)
  }

  func getSubfolders() -> [Folder] {
    folder.subfolders.map(DefaultFolder.init)
  }
}

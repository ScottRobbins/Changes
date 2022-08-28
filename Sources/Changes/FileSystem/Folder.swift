import Files
import Foundation

protocol Folder {
  func getFiles() -> [File]
  func createSubfolderIfNeeded(withName name: String) throws -> Folder
  func file(named name: String) throws -> File
  func getSubfolders() -> [Folder]
  func getParentFolder() -> Folder?
  func subfolder(named name: String) throws -> Folder
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

  func getParentFolder() -> Folder? {
    folder.parent.map(DefaultFolder.init)
  }

  func subfolder(named name: String) throws -> Folder {
    let subfolder = try folder.subfolder(named: name)
    return DefaultFolder(folder: subfolder)
  }

  static var current: Folder {
    DefaultFolder(folder: Files.Folder.current)
  }
}

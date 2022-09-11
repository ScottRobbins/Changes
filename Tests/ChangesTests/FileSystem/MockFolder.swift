import Foundation

@testable import Changes

class MockFolder: Folder {
  private(set) var name: String
  var parentFolder: MockFolder?
  private(set) var files: [MockFile]
  private(set) var subfolders: [MockFolder]

  init(
    _ name: String,
    files: [MockFile] = [],
    subfolders: [MockFolder] = []
  ) {
    self.name = name
    self.subfolders = subfolders
    self.files = files
  }

  var createSubfolderIfNeededErrorToThrow: Error?

  func getFiles() -> [File] {
    files
  }

  func createSubfolderIfNeeded(withName name: String) throws -> Folder {
    if let createSubfolderIfNeededErrorToThrow = createSubfolderIfNeededErrorToThrow {
      throw createSubfolderIfNeededErrorToThrow
    } else {
      let subfolder = MockFolder(name)
      subfolders.append(subfolder)
      return subfolder
    }
  }

  func file(named name: String) throws -> File {
    guard let file = (files.first { $0.name == name }) else {
      throw FileNotFound()
    }

    return file
  }

  func getSubfolders() -> [Folder] {
    return subfolders
  }

  func getParentFolder() -> Folder? {
    parentFolder
  }

  func subfolder(named name: String) throws -> Folder {
    guard let subfolder = (subfolders.first { $0.name == name }) else {
      throw SubfolderNotFound()
    }

    return subfolder
  }
}

struct FileNotFound: Error {}
struct SubfolderNotFound: Error {}

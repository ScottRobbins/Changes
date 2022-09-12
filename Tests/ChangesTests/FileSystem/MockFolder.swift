import Foundation

@testable import Changes

class MockFolder: Folder, MockFolderItem {
  private(set) var name: String
  var parentFolder: MockFolder?
  private(set) var files: [MockFile]
  private(set) var subfolders: [MockFolder]

  var createSubfolderIfNeededErrorToThrow: Error?

  init(
    _ name: String,
    files: [MockFile] = [],
    subfolders: [MockFolder] = []
  ) {
    self.name = name
    self.subfolders = subfolders
    self.files = files
  }

  init(_ name: String, @MockFolderBuilder content makeContent: () -> MockFolderContent) {
    self.name = name

    let content = makeContent()
    self.files = content.files
    self.subfolders = content.subfolders
    for subfolder in self.subfolders {
      subfolder.parentFolder = self
    }
  }

  func createSubfolderError(_ error: Error) -> MockFolder {
    let newFolder = MockFolder(name, files: files, subfolders: subfolders)
    newFolder.createSubfolderIfNeededErrorToThrow = error
    return newFolder
  }

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

  func mockFolderItemPossibility() -> MockFolderItemPossibility {
    .folder(self)
  }
}

struct FileNotFound: Error {}
struct SubfolderNotFound: Error {}

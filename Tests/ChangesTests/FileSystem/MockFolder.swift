import Foundation

@testable import Changes

class MockFolder: Folder {
  var getFilesToReturn: [File]!
  var createSubfolderIfNeededToReturn: Folder!
  var createSubfolderIfNeededErrorToThrow: Error?
  var fileNamedToReturn: File!
  var fileNamedErrorToThrow: Error?
  var getSubfoldersToReturn: [Folder]!
  var parentFolderToReturn: Folder?
  var subfolderNamedToReturn: Folder!
  var subfolderNamedErrorToThrow: Error?

  var namePassedToCreateSubfolderIfNeeded: String?
  var namePassedToFile: String?
  var namePassedToSubfolderNamed: String?

  func getFiles() -> [File] {
    getFilesToReturn
  }

  func createSubfolderIfNeeded(withName name: String) throws -> Folder {
    namePassedToCreateSubfolderIfNeeded = name

    if let createSubfolderIfNeededErrorToThrow = createSubfolderIfNeededErrorToThrow {
      throw createSubfolderIfNeededErrorToThrow
    } else {
      return createSubfolderIfNeededToReturn
    }
  }

  func file(named name: String) throws -> File {
    namePassedToFile = name

    if let fileNamedErrorToThrow = fileNamedErrorToThrow {
      throw fileNamedErrorToThrow
    } else {
      return fileNamedToReturn
    }
  }

  func getSubfolders() -> [Folder] {
    return getSubfoldersToReturn
  }

  func getParentFolder() -> Folder? {
    parentFolderToReturn
  }

  func subfolder(named name: String) throws -> Folder {
    namePassedToSubfolderNamed = name
    
    if let subfolderNamedErrorToThrow = subfolderNamedErrorToThrow {
      throw subfolderNamedErrorToThrow
    } else {
      return subfolderNamedToReturn
    }
  }
}

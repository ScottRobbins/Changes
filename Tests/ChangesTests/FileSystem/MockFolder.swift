import Foundation

@testable import Changes

class MockFolder: Folder {
  var getFilesToReturn: [File]!
  var createSubfolderIfNeededToReturn: Folder!
  var createSubfolderIfNeededErrorToThrow: Error?
  var fileNamedToReturn: File!
  var fileNamedErrorToThrow: Error?

  var namePassedToCreateSubfolderIfNeeded: String?
  var namePassedToFile: String?

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
}

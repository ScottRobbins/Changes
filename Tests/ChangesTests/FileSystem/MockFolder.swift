import Foundation

@testable import Changes

class MockFolder: Folder {
  var getFilesToReturn: [File]!
  var createSubfolderIfNeededToReturn: Folder!
  var createSubfolderIfNeededErrorToThrow: Error?

  var namePassedToCreateSubfolderIfNeeded: String?

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
}

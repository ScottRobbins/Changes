import Foundation

@testable import Changes

class MockFile: File {
  var nameExcludingExtensionToReturn: String!
  var readDataToReturn: Data!
  var readErrorToThrow: Error?

  var nameExcludingExtension: String {
    nameExcludingExtensionToReturn
  }

  func read() throws -> Data {
    if let readErrorToThrow = readErrorToThrow {
      throw readErrorToThrow
    } else {
      return readDataToReturn
    }
  }
}

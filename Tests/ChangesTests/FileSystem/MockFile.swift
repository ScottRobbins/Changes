import Foundation

@testable import Changes

class MockFile: File, MockFolderItem {
  let name: String
  let contents: Data

  var readErrorToThrow: Error?

  init(_ name: String, contents: Data) {
    self.name = name
    self.contents = contents
  }

  func readError(_ error: Error) -> MockFile {
    let newFile = MockFile(name, contents: contents)
    newFile.readErrorToThrow = error
    return newFile
  }

  var nameExcludingExtension: String {
    var components = name.components(separatedBy: ".")

    guard components.count > 1 else {
      return name
    }

    components.removeLast()
    return components.joined(separator: ".")
  }

  func read() throws -> Data {
    if let readErrorToThrow = readErrorToThrow {
      throw readErrorToThrow
    } else {
      return contents
    }
  }

  func readAsString() throws -> String {
    if let readErrorToThrow = readErrorToThrow {
      throw readErrorToThrow
    } else {
      return String(decoding: contents, as: UTF8.self)
    }
  }

  func mockFolderItemPossibility() -> MockFolderItemPossibility {
    .file(self)
  }
}

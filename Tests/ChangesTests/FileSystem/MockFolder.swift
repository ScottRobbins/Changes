import Foundation

@testable import Changes

class MockFolder: Folder {
  var getFilesToReturn: [File]!

  func getFiles() -> [File] {
    getFilesToReturn
  }
}

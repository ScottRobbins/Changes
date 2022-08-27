import Files
import Foundation

protocol File {
  var nameExcludingExtension: String { get }
  func read() throws -> Data
}

struct DefaultFile: File {
  let file: Files.File

  var nameExcludingExtension: String {
    file.nameExcludingExtension
  }

  func read() throws -> Data {
    try file.read()
  }
}

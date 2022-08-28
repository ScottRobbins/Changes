import Files
import Foundation

protocol File {
  var nameExcludingExtension: String { get }
  func read() throws -> Data
  func readAsString() throws -> String
}

struct DefaultFile: File {
  let file: Files.File

  var nameExcludingExtension: String {
    file.nameExcludingExtension
  }

  func read() throws -> Data {
    try file.read()
  }

  func readAsString() throws -> String {
    try file.readAsString()
  }
}

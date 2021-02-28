import Files
import Foundation

protocol File {
  func read() throws -> Data
}

extension Files.File: File { }
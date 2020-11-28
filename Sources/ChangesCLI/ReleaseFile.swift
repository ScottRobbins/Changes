import Foundation
import Version

struct ReleaseFile: Codable {
  let createdAtDate: Date
}

extension ReleaseFile {
  func release(version: Version) -> Release {
    return Release(version: version, createdAtDate: createdAtDate)
  }
}

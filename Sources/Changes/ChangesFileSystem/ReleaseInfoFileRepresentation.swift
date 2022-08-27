import Foundation
import Version

struct ReleaseInfoFileRepresentation: Codable {
  let version: Version
  let createdAtDate: Date
}

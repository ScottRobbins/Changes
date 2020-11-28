import Foundation
import Version

struct Release: Codable {
  let version: Version
  let createdAtDate: Date
}

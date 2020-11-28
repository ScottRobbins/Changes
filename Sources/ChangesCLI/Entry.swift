import Foundation

struct Entry: Codable {
  let id: String
  let tags: [String]
  let description: String
  let createdAtDate: Date
}

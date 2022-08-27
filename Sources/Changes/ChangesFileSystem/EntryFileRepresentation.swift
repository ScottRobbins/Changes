import Foundation

struct EntryFileRepresentation: Codable {
  let tags: [String]
  let description: String
  let createdAtDate: Date
}

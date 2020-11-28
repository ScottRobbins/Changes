import Foundation

struct ChangelogEntry: Codable {
  let tags: [String]
  let description: String
  let createdAtDate: Date

  init(
    tags: [String],
    description: String,
    createdAtDate: Date
  ) {
    self.tags = tags
    self.description = description
    self.createdAtDate = createdAtDate
  }
}

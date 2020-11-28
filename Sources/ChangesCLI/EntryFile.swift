import Foundation

struct EntryFile: Codable {
  let tags: [String]
  let description: String
  let createdAtDate: Date
}

extension EntryFile {
  func entry(id: String) -> Entry {
    return Entry(id: id, tags: tags, description: description, createdAtDate: createdAtDate)
  }
}

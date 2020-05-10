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

  init(
    from decoder: Decoder
  ) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    tags = try values.decode(Array<String>.self, forKey: .tags)
    description = try values.decode(String.self, forKey: .description)
    let _createdAtDate = try values.decode(String.self, forKey: .createdAtDate)

    guard let date = ISO8601DateFormatter().date(from: _createdAtDate) else {
      throw DecodingError.typeMismatch(
        String.self,
        DecodingError.Context(
          codingPath: [CodingKeys.createdAtDate],
          debugDescription: "createdAtDate"
        )
      )
    }
    createdAtDate = date
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(tags, forKey: .tags)
    try container.encode(description, forKey: .description)

    let dateString = ISO8601DateFormatter().string(from: createdAtDate)
    try container.encode(dateString, forKey: .createdAtDate)
  }

  enum CodingKeys: String, CodingKey {
    case tags
    case description
    case createdAtDate
  }
}

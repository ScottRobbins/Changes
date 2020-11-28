import Foundation
import Version

struct Release: Codable {
  let version: Version
  let createdAtDate: Date

  init(
    version: Version,
    createdAtDate: Date
  ) {
    self.version = version
    self.createdAtDate = createdAtDate
  }

  init(
    from decoder: Decoder
  ) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    version = try values.decode(Version.self, forKey: .version)
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
    try container.encode(version, forKey: .version)

    let dateString = ISO8601DateFormatter().string(from: createdAtDate)
    try container.encode(dateString, forKey: .createdAtDate)
  }

  enum CodingKeys: String, CodingKey {
    case version
    case createdAtDate
  }
}

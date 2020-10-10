import Foundation

struct ReleaseQueryItem: Codable {
  let version: String
  let createdAtDate: Date
  let prereleases: [PrereleaseQueryItem]

  init(version: String, createdAtDate: Date, prereleases: [PrereleaseQueryItem] = []) {
    self.version = version
    self.createdAtDate = createdAtDate
    self.prereleases = prereleases
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    version = try values.decode(String.self, forKey: .version)
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
    prereleases = try values.decode(Array<PrereleaseQueryItem>.self, forKey: .prereleases)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(version, forKey: .version)

    let dateString = ISO8601DateFormatter().string(from: createdAtDate)
    try container.encode(dateString, forKey: .createdAtDate)
    try container.encode(prereleases, forKey: .prereleases)
  }

  enum CodingKeys: String, CodingKey {
    case version
    case createdAtDate
    case prereleases
  }
}

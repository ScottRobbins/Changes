import Foundation

struct ReleaseQueryItem: Codable {
  let version: String
  let createdAtDate: Date
  let prereleases: [PrereleaseQueryItem]
}

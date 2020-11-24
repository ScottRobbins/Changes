import Foundation

struct ChangesQueryItem: Codable {
  let tags: [String]
  let description: String
  let createdAtDate: Date
  let release: String?
  let prerelease: String?
}

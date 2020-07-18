struct ChangesConfig: Codable {
  struct ChangelogFile: Codable {
    let identifier: String
    let path: String
    let tags: [String]
    let automaticallyRegenerate: Bool
    let footerText: String?
  }

  let tags: [String]
  let files: [ChangelogFile]
}

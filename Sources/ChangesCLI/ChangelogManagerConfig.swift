struct ChangesConfig: Codable {
  struct ChangelogFile: Codable {
    let path: String
    let tags: [String]
    let footerText: String?
  }

  let files: [ChangelogFile]
}

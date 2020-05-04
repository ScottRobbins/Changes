struct ChangelogManagerConfig: Codable {
  struct ChangelogFile: Codable {
    let path: String
    let categories: [String]
  }

  let files: [ChangelogFile]
}

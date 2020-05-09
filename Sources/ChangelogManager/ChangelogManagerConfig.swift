struct ChangelogManagerConfig: Codable {
  struct ChangelogFile: Codable {
    let path: String
    let tags: [String]
  }

  let files: [ChangelogFile]
}

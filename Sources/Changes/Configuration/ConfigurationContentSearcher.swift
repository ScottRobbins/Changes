import Files

struct ConfigurationContentSearcher {
  func getConfigurationContents() throws -> String {
    var _folder: Folder? = Folder.current
    while let folder = _folder {
      defer { _folder = folder.parent }

      if let configFile = try? folder.file(named: ".changes.yml"),
        let configString = try? configFile.readAsString()
      {
        return configString
      }
    }

    throw ConfigurationLoadError.missing("No config found.")
  }
}

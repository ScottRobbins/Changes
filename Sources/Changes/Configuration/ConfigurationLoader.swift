import Yams

struct ConfigurationLoader {
  func load() throws -> ChangesConfig {
    let configurationContents = try ConfigurationContentSearcher().getConfigurationContents()
    let decoder = YAMLDecoder()
    guard let config = try? decoder.decode(ChangesConfig.self, from: configurationContents) else {
      throw ConfigurationLoadError.invalidFormat("Invalid config file format.")
    }

    return config
  }
}

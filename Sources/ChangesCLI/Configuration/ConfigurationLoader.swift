import Files
import Yams

struct LoadedChangesConfig {
  let config: ChangesConfig
  let path: String
}

struct ConfigurationLoader {
  func load() throws -> LoadedChangesConfig {
    var _folder: Folder? = Folder.current
    while let folder = _folder {
      defer { _folder = folder.parent }

      if let configFile = try? folder.file(named: ".changes.yml"),
        let configString = try? configFile.readAsString()
      {
        let decoder = YAMLDecoder()
        guard let config = try? decoder.decode(ChangesConfig.self, from: configString) else {
          throw ChangesError("Invalid config file format.")
        }

        try validateConfig(config)

        return .init(config: config, path: configFile.path)
      }
    }

    throw ChangesError("No config found.")
  }

  private func validateConfig(_ config: ChangesConfig) throws {
    for file in config.files {
      guard !file.tags.isEmpty else {
        throw ChangesError(#"File "\#(file.identifier)" has no defined tags"#)
      }

      for tag in file.tags {
        guard config.tags.contains(tag) else {
          throw ChangesError(
            #"File "\#(file.identifier)" contains tag "\#(tag)" that is not defined at the configuration level"#
          )
        }
      }
    }
  }
}

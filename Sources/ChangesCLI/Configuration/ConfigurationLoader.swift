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

        return .init(config: config, path: configFile.path)
      }
    }
    
    throw ChangesError("No config found.")
  }
}

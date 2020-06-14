import Files
import Yams

struct ConfigurationLoaderError: Error, CustomStringConvertible {
  var message: String

  public init(
    _ message: String
  ) {
    self.message = message
  }

  public var description: String {
    message
  }
}

struct ConfigurationLoader {
  func load() throws -> ChangesConfig {
    guard let configPath = try? Folder.current.file(named: ".changes.yml").path,
      let configString = try? File(path: configPath).readAsString()
    else {
      throw ConfigurationLoaderError("No config found.")
    }

    let decoder = YAMLDecoder()
    guard let config = try? decoder.decode(ChangesConfig.self, from: configString) else {
      throw ConfigurationLoaderError("Invalid config file format.")
    }

    return config
  }
}

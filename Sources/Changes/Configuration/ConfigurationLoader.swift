import Yams

struct ConfigurationLoader {
  private let workingFolderFinder: WorkingFolderFinder

  init(workingFolderFinder: WorkingFolderFinder = WorkingFolderFinder()) {
    self.workingFolderFinder = workingFolderFinder
  }

  func load() throws -> ChangesConfig {
    let workingFolder = try workingFolderFinder.getWorkingFolder()
    guard let configFile = try? workingFolder.file(named: ".changes.yml") else {
      throw ConfigurationLoadError.missing("No config found.")
    }

    guard let configurationContents = try? configFile.readAsString() else {
      throw ConfigurationLoadError.fileReadError("Unable to read contents of configuration file")
    }

    let decoder = YAMLDecoder()
    guard let config = try? decoder.decode(ChangesConfig.self, from: configurationContents) else {
      throw ConfigurationLoadError.invalidFormat("Invalid config file format.")
    }

    return config
  }
}

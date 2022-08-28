import Foundation

struct ChangesFolderFinder {
  private let workingFolderFinder: WorkingFolderFinder
  private let decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  init(workingFolderFinder: WorkingFolderFinder) {
    self.workingFolderFinder = workingFolderFinder
  }

  func getChangesFolder() throws -> ChangesFolder {
    let workingFolder = try workingFolderFinder.getWorkingFolder()
    let _changesFolder = try workingFolder.subfolder(named: ".changes")
    return ChangesFolder(folder: _changesFolder, decoder: decoder)
  }
}

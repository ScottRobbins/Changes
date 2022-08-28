import Foundation

struct ChangesFolder {
  private let folder: Folder
  private let decoder: JSONDecoder

  init(folder: Folder, decoder: JSONDecoder) {
    self.folder = folder
    self.decoder = decoder
  }

  func unreleasedFolder() throws -> UnreleasedFolder {
    let unreleasedSubfolder = try folder.createSubfolderIfNeeded(withName: "unreleased")
    return UnreleasedFolder(folder: unreleasedSubfolder, decoder: decoder)
  }

  func releasesFolder() throws -> ReleasesFolder {
    let releasesSubfolder = try folder.createSubfolderIfNeeded(withName: "releases")
    return ReleasesFolder(folder: releasesSubfolder, decoder: decoder)
  }
}

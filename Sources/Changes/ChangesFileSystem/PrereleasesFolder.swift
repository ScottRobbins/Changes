import Foundation

struct PrereleasesFolder {
  private let folder: Folder
  private let decoder: JSONDecoder

  init(folder: Folder, decoder: JSONDecoder) {
    self.folder = folder
    self.decoder = decoder
  }

  func prereleaseFolders() -> [PrereleaseFolder] {
    folder.getSubfolders().map { .init(folder: $0, decoder: decoder) }
  }
}

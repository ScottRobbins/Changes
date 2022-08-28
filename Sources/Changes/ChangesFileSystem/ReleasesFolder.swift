import Foundation

struct ReleasesFolder {
  private let folder: Folder
  private let decoder: JSONDecoder

  init(folder: Folder, decoder: JSONDecoder) {
    self.folder = folder
    self.decoder = decoder
  }

  func releaseFolders() -> [ReleaseFolder] {
    folder.getSubfolders().map { .init(folder: $0, decoder: decoder) }
  }
}

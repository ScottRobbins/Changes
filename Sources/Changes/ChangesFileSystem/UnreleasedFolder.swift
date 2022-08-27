import Foundation

struct UnreleasedFolder {
  private let folder: Folder
  private let decoder: JSONDecoder

  init(folder: Folder, decoder: JSONDecoder) {
    self.folder = folder
    self.decoder = decoder
  }

  func entriesFolder() throws -> EntriesFolder {
    let entriesSubfolder = try folder.createSubfolderIfNeeded(withName: "entries")
    return EntriesFolder(folder: entriesSubfolder, decoder: decoder)
  }
}

import Foundation

struct PrereleaseFolder {
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

  func infoFile() throws -> ReleaseInfoFile {
    let _infoFile = try folder.file(named: "info.json")
    return ReleaseInfoFile(file: _infoFile, decoder: decoder)
  }
}

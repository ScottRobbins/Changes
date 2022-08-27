import Foundation

struct EntriesFolder {
  private let folder: Folder
  private let decoder: JSONDecoder

  init(folder: Folder, decoder: JSONDecoder) {
    self.folder = folder
    self.decoder = decoder
  }

  func entryFiles() -> [EntryFile] {
    folder.getFiles().map { .init(file: $0, decoder: decoder) }
  }
}

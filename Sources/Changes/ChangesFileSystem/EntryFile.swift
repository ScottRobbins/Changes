import Foundation

struct EntryFile {
  private let file: File
  private let decoder: JSONDecoder

  init(file: File, decoder: JSONDecoder) {
    self.file = file
    self.decoder = decoder
  }

  var id: String {
    return file.nameExcludingExtension
  }

  func read() throws -> Entry {
    let fileData = try file.read()
    let _entryFile = try decoder.decode(EntryFileRepresentation.self, from: fileData)
    return Entry(
      id: id,
      tags: _entryFile.tags,
      description: _entryFile.description,
      createdAtDate: _entryFile.createdAtDate
    )
  }
}

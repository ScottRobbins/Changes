import Foundation

struct ReleaseInfoFile {
  private let file: File
  private let decoder: JSONDecoder

  init(file: File, decoder: JSONDecoder) {
    self.file = file
    self.decoder = decoder
  }

  func read() throws -> ReleaseInfo {
    let fileData = try file.read()
    let _releaseInfoFile = try decoder.decode(ReleaseInfoFileRepresentation.self, from: fileData)
    return ReleaseInfo(
      version: _releaseInfoFile.version,
      createdAtDate: _releaseInfoFile.createdAtDate)
  }
}

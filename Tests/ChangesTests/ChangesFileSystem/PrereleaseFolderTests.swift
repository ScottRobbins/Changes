import XCTest

@testable import Changes

final class PrereleaseFolderTests: XCTestCase {
  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  func testEntriesFolderWhenFolderCanBeCreated() throws {
    // given
    let _prereleaseFolder = MockFolder("alpha.1")
    let prereleaseFolder = PrereleaseFolder(folder: _prereleaseFolder, decoder: decoder)

    // when & then
    XCTAssertNoThrow(try prereleaseFolder.entriesFolder())
  }

  func testEntriesFolderWhenFolderCannotBeCreated() {
    // given
    let _prereleaseFolder = MockFolder("alpha.1").createSubfolderError(TestError())
    let prereleaseFolder = PrereleaseFolder(folder: _prereleaseFolder, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try prereleaseFolder.entriesFolder())
  }

  func testInfoFileWhenFileCanBeFound() throws {
    // given
    let _prereleaseFolder = MockFolder("alpha.1") {
      MockFile("info.json", contents: Data())
    }
    let prereleaseFolder = PrereleaseFolder(folder: _prereleaseFolder, decoder: decoder)

    // when & then
    XCTAssertNoThrow(try prereleaseFolder.infoFile())
  }

  func testInfoFileWhenFileCannotBeFound() {
    // given
    let _prereleaseFolder = MockFolder("alpha.1")
    let prereleaseFolder = PrereleaseFolder(folder: _prereleaseFolder, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try prereleaseFolder.infoFile())
  }
}

private struct TestError: Error {}
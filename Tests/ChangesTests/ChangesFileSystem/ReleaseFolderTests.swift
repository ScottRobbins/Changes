import XCTest

@testable import Changes

final class ReleaseFolderTests: XCTestCase {
  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  func testEntriesFolderWhenFolderCanBeCreated() throws {
    // given
    let _releaseFolder = MockFolder("1.0.0")
    let releaseFolder = ReleaseFolder(folder: _releaseFolder, decoder: decoder)

    // when & then
    XCTAssertNoThrow(try releaseFolder.entriesFolder())
  }

  func testEntriesFolderWhenFolderCannotBeCreated() {
    // given
    let _releaseFolder = MockFolder("1.0.0")
    _releaseFolder.createSubfolderIfNeededErrorToThrow = TestError()
    let releaseFolder = ReleaseFolder(folder: _releaseFolder, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try releaseFolder.entriesFolder())
  }

  func testInfoFileWhenFileCanBeFound() throws {
    // given
    let infoFile = MockFile("info.json", contents: Data())
    let _releaseFolder = MockFolder("1.0.0", files: [infoFile])
    let releaseFolder = ReleaseFolder(folder: _releaseFolder, decoder: decoder)

    // when & then
    XCTAssertNoThrow(try releaseFolder.infoFile())
  }

  func testInfoFileWhenFileCannotBeFound() {
    // given
    let _releaseFolder = MockFolder("1.0.0")
    let releaseFolder = ReleaseFolder(folder: _releaseFolder, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try releaseFolder.infoFile())
  }

  func testPrereleasesFolderWhenFolderCanBeCreated() throws {
    // given
    let _releaseFolder = MockFolder("1.0.0")
    let releaseFolder = ReleaseFolder(folder: _releaseFolder, decoder: decoder)

    // when & then
    XCTAssertNoThrow(try releaseFolder.prereleasesFolder())
  }

  func testPrereleasesFolderWhenFolderCannotBeCreated() {
    // given
    let _releaseFolder = MockFolder("1.0.0")
    _releaseFolder.createSubfolderIfNeededErrorToThrow = TestError()
    let releaseFolder = ReleaseFolder(folder: _releaseFolder, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try releaseFolder.prereleasesFolder())
  }
}

private struct TestError: Error {}

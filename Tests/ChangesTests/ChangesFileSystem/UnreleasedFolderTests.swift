import XCTest

@testable import Changes

final class UnreleasedFolderTests: XCTestCase {
  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  func testEntriesFolderWhenFolderCanBeCreated() throws {
    // given
    let _unreleasedFolder = MockFolder("unreleased")
    let unreleasedFolder = UnreleasedFolder(folder: _unreleasedFolder, decoder: decoder)

    // when & then
    XCTAssertNoThrow(try unreleasedFolder.entriesFolder())
  }

  func testEntriesFolderWhenFolderCannotBeCreated() {
    // given
    let _unreleasedFolder = MockFolder("unreleased")
    _unreleasedFolder.createSubfolderIfNeededErrorToThrow = TestError()
    let unreleasedFolder = UnreleasedFolder(folder: _unreleasedFolder, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try unreleasedFolder.entriesFolder())
  }
}

private struct TestError: Error {}

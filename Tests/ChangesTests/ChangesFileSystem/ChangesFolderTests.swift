import XCTest

@testable import Changes

final class ChangesFolderTests: XCTestCase {
  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  func testUnreleasedFolderWhenFolderCanBeCreated() throws {
    // given
    let _changesFolder = MockFolder(".changes")
    let changesFolder = ChangesFolder(folder: _changesFolder, decoder: decoder)

    // when & then
    XCTAssertNoThrow(try changesFolder.unreleasedFolder())
  }

  func testUnreleasedFolderWhenFolderCannotBeCreated() {
    // given
    let _changesFolder = MockFolder(".changes").createSubfolderError(TestError())
    let changesFolder = ChangesFolder(folder: _changesFolder, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try changesFolder.unreleasedFolder())
  }

  func testReleasesFolderWhenFolderCanBeCreated() throws {
    // given
    let _changesFolder = MockFolder(".changes")
    let changesFolder = ChangesFolder(folder: _changesFolder, decoder: decoder)

    // when & then
    XCTAssertNoThrow(try changesFolder.releasesFolder())
  }

  func testReleasesFolderWhenFolderCannotBeCreated() {
    // given
    let _changesFolder = MockFolder(".changes").createSubfolderError(TestError())
    let changesFolder = ChangesFolder(folder: _changesFolder, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try changesFolder.releasesFolder())
  }
}

private struct TestError: Error {}

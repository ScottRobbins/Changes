import XCTest

@testable import Changes

final class ChangesFolderTests: XCTestCase {
  var mockFolder: MockFolder!
  var changesFolder: ChangesFolder!

  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  override func setUp() {
    mockFolder = MockFolder()
    changesFolder = ChangesFolder(folder: mockFolder, decoder: decoder)
  }

  func testUnreleasedFolderWhenFolderCanBeCreated() throws {
    // given
    let folderReturned = MockFolder()
    mockFolder.createSubfolderIfNeededToReturn = folderReturned

    // when
    let _ = try changesFolder.unreleasedFolder()

    // then
    XCTAssertEqual(mockFolder.namePassedToCreateSubfolderIfNeeded, "unreleased")
  }

  func testUnreleasedFolderWhenFolderCannotBeCreated() {
    // given
    mockFolder.createSubfolderIfNeededErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try changesFolder.unreleasedFolder())
  }

  func testReleasesFolderWhenFolderCanBeCreated() throws {
    // given
    let folderReturned = MockFolder()
    mockFolder.createSubfolderIfNeededToReturn = folderReturned

    // when
    let _ = try changesFolder.releasesFolder()

    // then
    XCTAssertEqual(mockFolder.namePassedToCreateSubfolderIfNeeded, "releases")
  }

  func testReleasesFolderWhenFolderCannotBeCreated() {
    // given
    mockFolder.createSubfolderIfNeededErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try changesFolder.releasesFolder())
  }
}

private struct TestError: Error {}

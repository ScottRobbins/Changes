import XCTest

@testable import Changes

final class UnreleasedFolderTests: XCTestCase {
  var mockFolder: MockFolder!
  var unreleasedFolder: UnreleasedFolder!

  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  override func setUp() {
    mockFolder = MockFolder()
    unreleasedFolder = UnreleasedFolder(folder: mockFolder, decoder: decoder)
  }

  func testEntriesFolderWhenFolderCanBeCreated() throws {
    let testFileId = "testFile"

    // given
    let testFile = MockFile()
    testFile.nameExcludingExtensionToReturn = testFileId
    let folderReturned = MockFolder()
    folderReturned.getFilesToReturn = [testFile]
    mockFolder.createSubfolderIfNeededToReturn = folderReturned

    // when
    let entriesFolder = try unreleasedFolder.entriesFolder()

    // then
    XCTAssertEqual(mockFolder.namePassedToCreateSubfolderIfNeeded, "entries")
    XCTAssertEqual(entriesFolder.entryFiles().first?.id, testFileId)
  }

  func testEntriesFolderWhenFolderCannotBeCreated() {
    // given
    mockFolder.createSubfolderIfNeededErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try unreleasedFolder.entriesFolder())
  }
}

private struct TestError: Error {}

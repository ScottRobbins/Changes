import XCTest

@testable import Changes

final class PrereleaseFolderTests: XCTestCase {
  var mockFolder: MockFolder!
  var prereleaseFolder: PrereleaseFolder!

  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  override func setUp() {
    mockFolder = MockFolder()
    prereleaseFolder = PrereleaseFolder(folder: mockFolder, decoder: decoder)
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
    let entriesFolder = try prereleaseFolder.entriesFolder()

    // then
    XCTAssertEqual(mockFolder.namePassedToCreateSubfolderIfNeeded, "entries")
    XCTAssertEqual(entriesFolder.entryFiles().first?.id, testFileId)
  }

  func testEntriesFolderWhenFolderCannotBeCreated() {
    // given
    mockFolder.createSubfolderIfNeededErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try prereleaseFolder.entriesFolder())
  }

  func testInfoFileWhenFileCanBeFound() throws {
    // given
    let testFile = MockFile()
    mockFolder.fileNamedToReturn = testFile

    // when
    let _ = try prereleaseFolder.infoFile()

    // then
    XCTAssertEqual(mockFolder.namePassedToFile, "info.json")
  }

  func testInfoFileWhenFileCannotBeFound() {
    // given
    mockFolder.fileNamedErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try prereleaseFolder.infoFile())
  }
}

private struct TestError: Error {}

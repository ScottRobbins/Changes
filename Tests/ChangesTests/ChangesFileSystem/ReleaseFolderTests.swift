import XCTest

@testable import Changes

final class ReleaseFolderTests: XCTestCase {
  var mockFolder: MockFolder!
  var releaseFolder: ReleaseFolder!

  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  override func setUp() {
    mockFolder = MockFolder()
    releaseFolder = ReleaseFolder(folder: mockFolder, decoder: decoder)
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
    let entriesFolder = try releaseFolder.entriesFolder()

    // then
    XCTAssertEqual(mockFolder.namePassedToCreateSubfolderIfNeeded, "entries")
    XCTAssertEqual(entriesFolder.entryFiles().first?.id, testFileId)
  }

  func testEntriesFolderWhenFolderCannotBeCreated() {
    // given
    mockFolder.createSubfolderIfNeededErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try releaseFolder.entriesFolder())
  }

  func testInfoFileWhenFileCanBeFound() throws {
    // given
    let testFile = MockFile()
    mockFolder.fileNamedToReturn = testFile

    // when
    let _ = try releaseFolder.infoFile()

    // then
    XCTAssertEqual(mockFolder.namePassedToFile, "info.json")
  }

  func testInfoFileWhenFileCannotBeFound() {
    // given
    mockFolder.fileNamedErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try releaseFolder.infoFile())
  }

  func testPrereleasesFolderWhenFolderCanBeCreated() throws {
    // given
    let folderReturned = MockFolder()
    mockFolder.createSubfolderIfNeededToReturn = folderReturned

    // when
    let _ = try releaseFolder.prereleasesFolder()

    // then
    XCTAssertEqual(mockFolder.namePassedToCreateSubfolderIfNeeded, "prereleases")
  }

  func testPrereleasesFolderWhenFolderCannotBeCreated() {
    // given
    mockFolder.createSubfolderIfNeededErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try releaseFolder.prereleasesFolder())
  }
}

private struct TestError: Error {}

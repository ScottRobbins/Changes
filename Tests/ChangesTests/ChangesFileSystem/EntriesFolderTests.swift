import XCTest

@testable import Changes

final class EntriesFolderTests: XCTestCase {
  var mockFolder: MockFolder!
  var entriesFolder: EntriesFolder!

  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  override func setUp() {
    mockFolder = MockFolder()
    entriesFolder = EntriesFolder(folder: mockFolder, decoder: decoder)
  }

  func testEntryFiles() {
    let testFile1Id = "testFile1"
    let testFile2Id = "testFile2"

    // given
    let testFile1 = MockFile()
    testFile1.nameExcludingExtensionToReturn = testFile1Id

    let testFile2 = MockFile()
    testFile2.nameExcludingExtensionToReturn = testFile2Id
    mockFolder.getFilesToReturn = [testFile1, testFile2]

    // when
    let entryFiles = entriesFolder.entryFiles()

    // then
    XCTAssertEqual(entryFiles.count, 2)
    if entryFiles.count == 2 {
      let entryFile1 = entryFiles[0]
      let entryFile2 = entryFiles[1]

      XCTAssertEqual(entryFile1.id, testFile1Id)
      XCTAssertEqual(entryFile2.id, testFile2Id)
    }
  }
}

import XCTest

@testable import Changes

final class EntriesFolderTests: XCTestCase {
  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  func testEntryFiles() {
    let testFile1Id = "testFile1"
    let testFile2Id = "testFile2"

    // given
    let testFile1 = MockFile("\(testFile1Id).json", contents: Data())
    let testFile2 = MockFile("\(testFile2Id).json", contents: Data())
    let _entriesFolder = MockFolder("entries", files: [testFile1, testFile2])
    let entriesFolder = EntriesFolder(folder: _entriesFolder, decoder: decoder)

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

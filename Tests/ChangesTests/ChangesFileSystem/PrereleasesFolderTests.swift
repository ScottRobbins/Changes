import XCTest

@testable import Changes

final class PrereleasesFolderTests: XCTestCase {
  var mockFolder: MockFolder!
  var prereleasesFolder: PrereleasesFolder!

  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  override func setUp() {
    mockFolder = MockFolder()
    prereleasesFolder = PrereleasesFolder(folder: mockFolder, decoder: decoder)
  }

  func testPrereleaseFolders() {
    // given
    let testFolder1 = MockFolder()
    let testFolder2 = MockFolder()

    mockFolder.getSubfoldersToReturn = [testFolder1, testFolder2]

    // when
    let prereleaseFolders = prereleasesFolder.prereleaseFolders()

    // then
    XCTAssertEqual(prereleaseFolders.count, 2)
  }
}

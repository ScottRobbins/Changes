import XCTest

@testable import Changes

final class ReleasesFolderTests: XCTestCase {
  var mockFolder: MockFolder!
  var prereleasesFolder: ReleasesFolder!

  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  override func setUp() {
    mockFolder = MockFolder()
    prereleasesFolder = ReleasesFolder(folder: mockFolder, decoder: decoder)
  }

  func testPrereleaseFolders() {
    // given
    let testFolder1 = MockFolder()
    let testFolder2 = MockFolder()

    mockFolder.getSubfoldersToReturn = [testFolder1, testFolder2]

    // when
    let releaseFolders = prereleasesFolder.releaseFolders()

    // then
    XCTAssertEqual(releaseFolders.count, 2)
  }
}

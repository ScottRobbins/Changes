import XCTest

@testable import Changes

final class ReleasesFolderTests: XCTestCase {
  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  func testReleaseFolders() {
    // given
    let testFolder1 = MockFolder("1.0.0")
    let testFolder2 = MockFolder("1.1.0")
    let _releasesFolder = MockFolder("releases", subfolders: [testFolder1, testFolder2])
    let releasesFolder = ReleasesFolder(folder: _releasesFolder, decoder: decoder)

    // when
    let releaseFolders = releasesFolder.releaseFolders()

    // then
    XCTAssertEqual(releaseFolders.count, 2)
  }
}

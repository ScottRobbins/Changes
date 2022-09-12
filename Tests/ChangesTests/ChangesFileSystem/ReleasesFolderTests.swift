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
    let _releasesFolder = MockFolder("releases") {
      MockFolder("1.0.0")
      MockFolder("1.1.0")
    }
    let releasesFolder = ReleasesFolder(folder: _releasesFolder, decoder: decoder)

    // when
    let releaseFolders = releasesFolder.releaseFolders()

    // then
    XCTAssertEqual(releaseFolders.count, 2)
  }
}

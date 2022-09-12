import XCTest

@testable import Changes

final class PrereleasesFolderTests: XCTestCase {
  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  func testPrereleaseFolders() {
    // given
    let _prereleasesFolder = MockFolder("prereleases") {
      MockFolder("alpha.1")
      MockFolder("alpha.2")
    }
    let prereleasesFolder = PrereleasesFolder(folder: _prereleasesFolder, decoder: decoder)

    // when
    let prereleaseFolders = prereleasesFolder.prereleaseFolders()

    // then
    XCTAssertEqual(prereleaseFolders.count, 2)
  }
}

import Version
import XCTest

@testable import Changes

final class ReleaseInfoFileTests: XCTestCase {
  lazy var decoder: JSONDecoder = {
    let _decoder = JSONDecoder()
    _decoder.dateDecodingStrategy = .iso8601
    return _decoder
  }()

  lazy var encoder: JSONEncoder = {
    let _encoder = JSONEncoder()
    _encoder.dateEncodingStrategy = .iso8601
    return _encoder
  }()

  func testReadWhenDataIsValidShouldReturnReleaseInfo() throws {
    let version = Version(major: 1, minor: 0, patch: 0, prerelease: "alpha.1")
    let createdAtDate = ISO8601DateFormatter().date(from: "2022-08-27T00:00:00+0000")!

    // given
    let entryFileRepresentation = ReleaseInfoFileRepresentation(
      version: version,
      createdAtDate: createdAtDate
    )
    let data = try encoder.encode(entryFileRepresentation)
    let mockFile = MockFile("info.json", contents: data)
    let releaseInfoFile = ReleaseInfoFile(file: mockFile, decoder: decoder)

    // when
    let entry = try releaseInfoFile.read()

    // then
    XCTAssertEqual(entry.version, version)
    XCTAssertEqual(entry.createdAtDate, createdAtDate)
  }

  func testReadWhenCannotReadFileShouldThrowError() {
    // given
    let mockFile = MockFile("info.json", contents: Data())
    mockFile.readErrorToThrow = TestError()
    let releaseInfoFile = ReleaseInfoFile(file: mockFile, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try releaseInfoFile.read())
  }

  func testReadWhenDataIsInvalidShouldThrowError() {
    // given
    let invalidData = Data()
    let mockFile = MockFile("info.json", contents: invalidData)
    let releaseInfoFile = ReleaseInfoFile(file: mockFile, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try releaseInfoFile.read())
  }
}

private struct TestError: Error {}

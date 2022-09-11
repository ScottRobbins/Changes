import XCTest

@testable import Changes

final class EntryFileTests: XCTestCase {
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

  func testReadWhenDataIsValidShouldReturnEntry() throws {
    let id = "test"
    let tags = ["test"]
    let description = "test"
    let createdAtDate = ISO8601DateFormatter().date(from: "2022-08-27T00:00:00+0000")!

    // given
    let entryFileRepresentation = EntryFileRepresentation(
      tags: tags,
      description: description,
      createdAtDate: createdAtDate
    )
    let data = try encoder.encode(entryFileRepresentation)
    let mockFile = MockFile("\(id).json", contents: data)
    let entryFile = EntryFile(file: mockFile, decoder: decoder)

    // when
    let entry = try entryFile.read()

    // then
    XCTAssertEqual(entry.id, id)
    XCTAssertEqual(entry.tags, tags)
    XCTAssertEqual(entry.description, description)
    XCTAssertEqual(entry.createdAtDate, createdAtDate)
  }

  func testReadWhenCannotReadFileShouldThrowError() {
    let id = "test"

    // given
    let mockFile = MockFile("\(id).json", contents: Data())
    mockFile.readErrorToThrow = TestError()
    let entryFile = EntryFile(file: mockFile, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try entryFile.read())
  }

  func testReadWhenDataIsInvalidShouldThrowError() {
    let id = "test"

    // given
    let invalidData = Data()
    let mockFile = MockFile("\(id).json", contents: invalidData)
    let entryFile = EntryFile(file: mockFile, decoder: decoder)

    // when & then
    XCTAssertThrowsError(try entryFile.read())
  }
}

private struct TestError: Error {}

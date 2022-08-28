import XCTest

@testable import Changes

final class WorkingFolderFinderTests: XCTestCase {
  var mockFolder: MockFolder!
  var workingFolderFinder: WorkingFolderFinder!

  override func setUp() {
    mockFolder = MockFolder()
    workingFolderFinder = WorkingFolderFinder(currentFolder: mockFolder)
  }

  func testGetWorkingFolderWhenInWorkingFolder() {
    // given
    mockFolder.subfolderNamedToReturn = MockFolder()

    // when & then
    XCTAssertNoThrow(try workingFolderFinder.getWorkingFolder())
  }

  func testGetWorkingFolderWhenWorkingFolderIsInParentDirectory() throws {
    // given
    mockFolder.subfolderNamedErrorToThrow = TestError()
    let parentFolder = MockFolder()
    parentFolder.subfolderNamedToReturn = MockFolder()
    mockFolder.parentFolderToReturn = parentFolder

    // when & then
    XCTAssertNoThrow(try workingFolderFinder.getWorkingFolder())
  }

  func testGetWorkingFolderWhenWorkingFolderDoesNotExist() {
    // given
    mockFolder.subfolderNamedErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try workingFolderFinder.getWorkingFolder())
  }
}

private struct TestError: Error {}

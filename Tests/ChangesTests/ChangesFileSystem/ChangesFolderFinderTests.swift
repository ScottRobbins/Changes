import XCTest

@testable import Changes

final class ChangesFolderFinderTests: XCTestCase {
  var mockFolder: MockFolder!
  var changesFolderFinder: ChangesFolderFinder!

  override func setUp() {
    mockFolder = MockFolder()
    let workingFolderFinder = WorkingFolderFinder(currentFolder: mockFolder)
    changesFolderFinder = ChangesFolderFinder(workingFolderFinder: workingFolderFinder)
  }

  func testGetChangesWhenNoWorkingFolder() {
    // given
    mockFolder.subfolderNamedErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try changesFolderFinder.getChangesFolder())
  }

  func testGetChangesWhenChangesFolderCanBeFound() {
    // given
    let changesFolder = MockFolder()
    mockFolder.subfolderNamedToReturn = changesFolder

    // when
    XCTAssertNoThrow(try changesFolderFinder.getChangesFolder())
    XCTAssertEqual(mockFolder.namePassedToSubfolderNamed, ".changes")
  }
}

private struct TestError: Error {}

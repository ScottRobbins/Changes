import XCTest

@testable import Changes

final class ChangesFolderFinderTests: XCTestCase {
  func testGetChangesWhenNoWorkingFolder() {
    // given
    let currentFolder = MockFolder("Changes")
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let changesFolderFinder = ChangesFolderFinder(workingFolderFinder: workingFolderFinder)

    // when & then
    XCTAssertThrowsError(try changesFolderFinder.getChangesFolder())
  }

  func testGetChangesWhenChangesFolderCanBeFound() {
    // given
    let changesFolder = MockFolder(".changes")
    let currentFolder = MockFolder("Changes", subfolders: [changesFolder])
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let changesFolderFinder = ChangesFolderFinder(workingFolderFinder: workingFolderFinder)

    // when
    XCTAssertNoThrow(try changesFolderFinder.getChangesFolder())
  }
}

private struct TestError: Error {}

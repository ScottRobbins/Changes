import XCTest

@testable import Changes

final class WorkingFolderFinderTests: XCTestCase {
  func testGetWorkingFolderWhenInWorkingFolder() {
    // given
    let changesFolder = MockFolder(".changes")
    let currentFolder = MockFolder(
      "Changes",
      subfolders: [changesFolder]
    )
    changesFolder.parentFolder = currentFolder
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)

    // when & then
    XCTAssertNoThrow(try workingFolderFinder.getWorkingFolder())
  }

  func testGetWorkingFolderWhenWorkingFolderIsInParentDirectory() throws {
    // given
    let changesFolder = MockFolder(".changes")
    let workingFolder = MockFolder(
      "Changes",
      subfolders: [changesFolder]
    )
    changesFolder.parentFolder = workingFolder
    let currentFolder = MockFolder("subfolder")
    currentFolder.parentFolder = workingFolder
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)

    // when & then
    XCTAssertNoThrow(try workingFolderFinder.getWorkingFolder())
  }

  func testGetWorkingFolderWhenWorkingFolderDoesNotExist() {
    // given
    let currentFolder = MockFolder("Changes")
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)

    // when & then
    XCTAssertThrowsError(try workingFolderFinder.getWorkingFolder())
  }
}

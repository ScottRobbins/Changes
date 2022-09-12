import XCTest

@testable import Changes

final class WorkingFolderFinderTests: XCTestCase {
  func testGetWorkingFolderWhenInWorkingFolder() {
    // given
    let currentFolder = MockFolder("Changes") {
      MockFolder(".changes")
    }
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)

    // when & then
    XCTAssertNoThrow(try workingFolderFinder.getWorkingFolder())
  }

  func testGetWorkingFolderWhenWorkingFolderIsInParentDirectory() throws {
    // given
    let currentFolder = MockFolder("subfolder")
    let _ = MockFolder("Changes") {
      currentFolder
      MockFolder(".changes")
    }
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

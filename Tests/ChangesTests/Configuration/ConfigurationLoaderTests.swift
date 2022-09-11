import XCTest
import Yams

@testable import Changes

final class ConfigurationLoaderTests: XCTestCase {
  func testLoadWhenValidConfigurationFile() throws {
    let tag = "test"

    // given
    let changesFolder = MockFolder(".changes")
    let changesConfigToReturn = ChangesConfig(tags: [tag], files: [])
    let changesContentsString = try YAMLEncoder().encode(changesConfigToReturn)
    let changesContentsData = changesContentsString.data(using: .utf8)!
    let configurationFile = MockFile(".changes.yml", contents: changesContentsData)
    let currentFolder = MockFolder(
      "Changes",
      files: [configurationFile],
      subfolders: [changesFolder]
    )
    changesFolder.parentFolder = currentFolder
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)

    // when
    let changesConfig = try configurationLoader.load()

    // then
    XCTAssertEqual(changesConfig.tags.first, tag)
  }

  func testLoadWhenNoWorkingFolder() {
    // given
    let currentFolder = MockFolder("Changes")
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }

  func testLoadWhenNoConfigurationFile() {
    // given
    let changesFolder = MockFolder(".changes")
    let currentFolder = MockFolder("Changes", subfolders: [changesFolder])
    changesFolder.parentFolder = currentFolder
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }

  func testLoadWhenConfigurationFileCannotBeRead() throws {
    // given
    let tag = "test"
    let changesFolder = MockFolder(".changes")
    let changesConfigToReturn = ChangesConfig(tags: [tag], files: [])
    let changesContentsString = try YAMLEncoder().encode(changesConfigToReturn)
    let changesContentsData = changesContentsString.data(using: .utf8)!
    let configurationFile = MockFile(".changes.yml", contents: changesContentsData)
    configurationFile.readErrorToThrow = TestError()
    let currentFolder = MockFolder(
      "Changes",
      files: [configurationFile],
      subfolders: [changesFolder]
    )
    changesFolder.parentFolder = currentFolder
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }

  func testLoadWhenInvalidConfigurationFile() {
    // given
    let changesFolder = MockFolder(".changes")
    let changesContentsData = Data()
    let configurationFile = MockFile(".changes.yml", contents: changesContentsData)
    let currentFolder = MockFolder(
      "Changes",
      files: [configurationFile],
      subfolders: [changesFolder]
    )
    changesFolder.parentFolder = currentFolder
    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }
}

private struct TestError: Error {}

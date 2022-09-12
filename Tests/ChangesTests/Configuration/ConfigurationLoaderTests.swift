import XCTest
import Yams

@testable import Changes

final class ConfigurationLoaderTests: XCTestCase {
  func testLoadWhenValidConfigurationFile() throws {
    let tag = "test"

    // given
    let changesConfigToReturn = ChangesConfig(tags: [tag], files: [])
    let changesContentsString = try YAMLEncoder().encode(changesConfigToReturn)
    let changesContentsData = changesContentsString.data(using: .utf8)!
    let currentFolder = MockFolder("Changes") {
      MockFile(".changes.yml", contents: changesContentsData)
      MockFolder(".changes")
    }

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
    let currentFolder = MockFolder("Changes") {
      MockFolder(".changes")
    }

    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }

  func testLoadWhenConfigurationFileCannotBeRead() throws {
    // given
    let tag = "test"
    let changesConfigToReturn = ChangesConfig(tags: [tag], files: [])
    let changesContentsString = try YAMLEncoder().encode(changesConfigToReturn)
    let changesContentsData = changesContentsString.data(using: .utf8)!
    let currentFolder = MockFolder("Changes") {
      MockFile(".changes.yml", contents: changesContentsData)
        .readError(TestError())

      MockFolder(".changes")
    }

    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }

  func testLoadWhenInvalidConfigurationFile() {
    // given
    let currentFolder = MockFolder("Changes") {
      MockFile(".changes.yml", contents: Data())
      MockFolder(".changes")
    }

    let workingFolderFinder = WorkingFolderFinder(currentFolder: currentFolder)
    let configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }
}

private struct TestError: Error {}

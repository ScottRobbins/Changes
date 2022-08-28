import XCTest
import Yams

@testable import Changes

final class ConfigurationLoaderTests: XCTestCase {
  var mockFolder: MockFolder!
  var configurationLoader: ConfigurationLoader!

  override func setUp() {
    mockFolder = MockFolder()
    let workingFolderFinder = WorkingFolderFinder(currentFolder: mockFolder)
    configurationLoader = ConfigurationLoader(workingFolderFinder: workingFolderFinder)
  }

  func testLoadWhenValidConfigurationFile() throws {
    let tag = "test"

    // given
    let changesFolder = MockFolder()
    let configurationFile = MockFile()
    let changesConfigToReturn = ChangesConfig(tags: [tag], files: [])
    let changesContents = try YAMLEncoder().encode(changesConfigToReturn)
    configurationFile.readStringToReturn = changesContents
    mockFolder.fileNamedToReturn = configurationFile
    mockFolder.subfolderNamedToReturn = changesFolder

    // when
    let changesConfig = try configurationLoader.load()

    // then
    XCTAssertEqual(changesConfig.tags.first, tag)
  }

  func testLoadWhenNoWorkingFolder() {
    // given
    mockFolder.subfolderNamedErrorToThrow = TestError()

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }

  func testLoadWhenNoConfigurationFile() {
    // given
    let changesFolder = MockFolder()
    mockFolder.fileNamedErrorToThrow = TestError()
    mockFolder.subfolderNamedToReturn = changesFolder

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }

  func testLoadWhenConfigurationFileCannotBeRead() {
    // given
    let changesFolder = MockFolder()
    let configurationFile = MockFile()
    configurationFile.readErrorToThrow = TestError()
    mockFolder.fileNamedToReturn = configurationFile
    mockFolder.subfolderNamedToReturn = changesFolder

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }

  func testLoadWhenInvalidConfigurationFile() {
    // given
    let changesFolder = MockFolder()
    let configurationFile = MockFile()
    configurationFile.readStringToReturn = ""
    mockFolder.fileNamedToReturn = configurationFile
    mockFolder.subfolderNamedToReturn = changesFolder

    // when & then
    XCTAssertThrowsError(try configurationLoader.load())
  }
}

private struct TestError: Error {}

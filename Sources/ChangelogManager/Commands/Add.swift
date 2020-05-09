import ArgumentParser
import Files
import Foundation
import Version
import Yams

struct Add: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "add",
    abstract: "Add a new changelog entry"
  )

  @Option(
    help: .init(
      "Specify a tag for your changelog entry."
    )
  )
  var tag: String?

  @Option(
    help: .init(
      "Specify a description for your changelog entry."
    )
  )
  var description: String?

  @Option(
    help: .init(
      #"Specify a release you would like to add this changelog entry to. By default it will be added to the "Unreleased" section."#
    )
  )
  var release: Version?

  func validate() throws {
    guard
      let configString = try? Folder.current.file(named: ".changelog-manager.yml").readAsString()
    else {
      throw ValidationError("No config found.")
    }

    let decoder = YAMLDecoder()
    guard let config = try? decoder.decode(ChangelogManagerConfig.self, from: configString) else {
      throw ValidationError("Invalid config file format.")
    }

    if let tag = tag {
      guard Set(allTags(with: config)).contains(tag) else {
        throw ValidationError("Tag specified is not used for any files in config.")
      }
    }

    if let release = release {
      guard let _ = try? Folder.current.subfolder(at: ".changelog-manager/releases/\(release)")
      else {
        throw ValidationError("Release \(release) was not found.")
      }
    }
  }

  func run() throws {
    guard
      let configString = try? Folder.current.file(named: ".changelog-manager.yml").readAsString()
    else {
      throw ValidationError("No config found.")
    }

    let decoder = YAMLDecoder()
    guard let config = try? decoder.decode(ChangelogManagerConfig.self, from: configString) else {
      throw ValidationError("Invalid config file format.")
    }

    let tag = self.tag ?? getTag(with: config)
    let description = self.description ?? getDescription()

    let outputFolder: Folder
    if let release = release {
      outputFolder = try Folder.current.createSubfolderIfNeeded(
        at: ".changelog-manager/releases/\(release)/entries"
      )
    }
    else {
      outputFolder = try Folder.current.subfolder(named: ".changelog-manager/Unreleased")
    }

    let entry = ChangelogEntry(
      tag: tag,
      description: description,
      createdAtDate: Date()
    )
    let encoder = YAMLEncoder()
    let outputString = try encoder.encode(entry)

    try outputFolder.createFile(named: "\(UUID().uuidString).yml").write(outputString)
    try ChangelogGenerator().regenerateChangelogs()
  }

  private func getTag(with config: ChangelogManagerConfig) -> String {
    let _allTags = allTags(with: config)
    let tagString = _allTags.enumerated().map { (tag) -> String in
      "[\(tag.offset)]  \(tag.element)"
    }.joined(separator: "\n")
    print(
      """
      Select a tag from:

      \(tagString)

      """
    )

    while true {
      print("Enter the tag:", terminator: " ")
      let readTag = (readLine() ?? "").trimmingCharacters(in: .whitespaces)

      if let number = Int(argument: readTag) {
        if let tag = _allTags.element(atIndex: number) {
          return tag
        }
        else {
          print("\(number) is not a valid entry.")
        }
      }
      else if readTag.isEmpty {
        print("Please enter a tag.")
      }
      else if Set(_allTags).contains(readTag) {
        return readTag
      }
      else {
        print("\(readTag) is not a valid tag")
      }
    }
  }

  private func getDescription() -> String {
    while true {
      print("Enter a description for this change:", terminator: " ")
      let description = (readLine() ?? "").trimmingCharacters(
        in: .whitespaces
      )
      if description.isEmpty {
        print("Please enter a description.")
      }
      else {
        return description
      }
    }
  }

  private func allTags(with config: ChangelogManagerConfig) -> [String] {
    Array(config.files.map(\.tags).joined())
  }
}

extension Version: ExpressibleByArgument {
  public init?(
    argument: String
  ) {
    if let version = try? Version(argument) {
      self = version
    }
    else {
      return nil
    }
  }
}

import ArgumentParser
import Files
import Foundation
import Version

struct Add: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "add",
    abstract: "Add a new changelog entry."
  )

  @Option(
    name: .shortAndLong,
    parsing: .upToNextOption,
    help: .init(
      "Specify one or more tags for your changelog entry."
    )
  )
  var tags: [String] = []

  @Option(
    name: .shortAndLong,
    help: .init(
      "Specify a description for your changelog entry."
    )
  )
  var description: String?

  @Option(
    name: .shortAndLong,
    help: .init(
      #"Specify a release you would like to add this changelog entry to. By default it will be added to the "Unreleased" section."#
    )
  )
  var release: Version?

  func validate() throws {
    let loadedConfig = try ConfigurationLoader().load()
    guard let workingFolder = try File(path: loadedConfig.path).parent else {
      throw ValidationError("Could not find folder of changes config.")
    }

    for tag in tags {
      guard definedTag(matching: tag, with: loadedConfig.config) != nil else {
        throw ValidationError("Tag \(tag) specified is not defined in the config.")
      }
    }

    if let release = release {
      if release.isPrerelease {
        guard
          let _ = try? workingFolder.subfolder(
            at: ".changes/releases/\(release.release)/prereleases/\(release.droppingBuildMetadata)"
          )
        else {
          throw ValidationError("Release \(release.droppingBuildMetadata) was not found.")
        }
      } else {
        guard
          let _ = try? workingFolder.subfolder(
            at: ".changes/releases/\(release.release)"
          )
        else {
          throw ValidationError("Release \(release.release) was not found.")
        }
      }
    }
  }

  func run() throws {
    let loadedConfig = try ConfigurationLoader().load()
    guard let workingFolder = try File(path: loadedConfig.path).parent else {
      throw ValidationError("Could not find folder of changes config.")
    }

    let tags: [String]
    if self.tags.isEmpty {
      tags = getTags(with: loadedConfig.config)
    } else {
      tags = self.tags.compactMap { definedTag(matching: $0, with: loadedConfig.config) }
    }

    let description = self.description ?? getDescription()

    let outputFolder: Folder
    if let release = release {
      if release.isPrerelease {
        outputFolder = try workingFolder.createSubfolderIfNeeded(
          at:
            ".changes/releases/\(release.release)/prereleases/\(release.droppingBuildMetadata)/entries"
        )
      } else {
        outputFolder = try workingFolder.createSubfolderIfNeeded(
          at: ".changes/releases/\(release.release)/entries"
        )
      }
    } else {
      outputFolder = try workingFolder.createSubfolderIfNeeded(at: ".changes/unreleased/entries")
    }

    let date = Date()
    let entry = EntryFile(
      tags: tags,
      description: description,
      createdAtDate: date
    )
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    let outputString = try encoder.encode(entry)

    try outputFolder.createFile(named: "\(UUID().uuidString).json").write(
      outputString
    )
  }

  private func getTags(with config: ChangesConfig) -> [String] {
    let allTags = config.tags
    let tagString =
      allTags.enumerated().map { (tag) -> String in
        "[\(tag.offset)]  \(tag.element)"
      }.joined(separator: "\n")
    print(
      """
      Select one or more tags from:

      \(tagString)

      """
    )

    var enteredTags = [String]()
    while true {
      if enteredTags.isEmpty {
        print("Enter a tag:", terminator: " ")
      } else {
        print("Enter another tag (Press enter if done):", terminator: " ")
      }

      let readTag = (readLine() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

      if readTag.isEmpty && !enteredTags.isEmpty {
        return enteredTags
      } else if let number = Int(argument: readTag) {
        if let tag = allTags.element(atIndex: number) {
          enteredTags.append(tag)
        } else {
          print("\(number) is not a valid entry.")
        }
      } else if readTag.isEmpty {
        print("Please enter a tag.")
      } else if let tag = definedTag(matching: readTag, with: config) {
        enteredTags.append(tag)
      } else {
        print("\(readTag) is not a valid tag")
      }
    }
  }

  private func getDescription() -> String {
    while true {
      print("Enter a description for this change:", terminator: " ")
      let description = (readLine() ?? "").trimmingCharacters(
        in: .whitespacesAndNewlines
      )
      if description.isEmpty {
        print("Please enter a description.")
      } else {
        return description
      }
    }
  }

  private func definedTag(matching tag: String, with config: ChangesConfig) -> String? {
    return config.tags.first { $0.lowercased() == tag.lowercased() }
  }
}

extension Version: ExpressibleByArgument {
  public init?(
    argument: String
  ) {
    if let version = try? Version(argument) {
      self = version
    } else {
      return nil
    }
  }
}

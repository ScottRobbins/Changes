import ArgumentParser
import Files
import Foundation
import Yams

struct Add: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "add",
    abstract: "Add a new changelog entry"
  )

  @Option(
    help: .init(
      "Specify a category for your changelog entry."
    )
  )
  var category: String?

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
  var release: String?

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

    if let category = category {
      guard Set(allCategories(with: config)).contains(category) else {
        throw ValidationError("Category specified is not used for any files in config.")
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

    let category = self.category ?? getCategory(with: config)
    let description = self.description ?? getDescription()

    let outputFolder: Folder
    if let release = release {
      outputFolder = try Folder.current.subfolder(at: ".changelog-manager/releases/\(release)")
    }
    else {
      outputFolder = try Folder.current.subfolder(named: ".changelog-manager/Unreleased")
    }

    let entry = ChangelogEntry(category: category, description: description)
    let encoder = YAMLEncoder()
    let outputString = try encoder.encode(entry)

    try outputFolder.createFile(named: "\(UUID().uuidString).yml").write(outputString)
  }

  private func getCategory(with config: ChangelogManagerConfig) -> String {
    let _allCategories = allCategories(with: config)
    let categoryString = _allCategories.enumerated().map { (category) -> String in
      "[\(category.offset)]  \(category.element)"
    }.joined(separator: "\n")
    print(
      """
      Select a category from:

      \(categoryString)

      """
    )

    while true {
      print("Enter the category:", terminator: " ")
      let readCategory = (readLine() ?? "").trimmingCharacters(in: .whitespaces)

      if let number = Int(argument: readCategory) {
        if let category = _allCategories.element(atIndex: number) {
          return category
        }
        else {
          print("\(number) is not a valid entry.")
        }
      }
      else if readCategory.isEmpty {
        print("Please enter a category.")
      }
      else if Set(_allCategories).contains(readCategory) {
        return readCategory
      }
      else {
        print("\(readCategory) is not a valid category")
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

  private func allCategories(with config: ChangelogManagerConfig) -> [String] {
    Array(config.files.map(\.categories).joined())
  }
}

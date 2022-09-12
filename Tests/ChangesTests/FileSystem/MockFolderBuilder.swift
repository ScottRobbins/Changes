@resultBuilder
struct MockFolderBuilder {
  static func buildBlock(_ parts: MockFolderItem...) -> MockFolderContent {
    var subfolders = [MockFolder]()
    var files = [MockFile]()
    for part in parts {
      switch part.mockFolderItemPossibility() {
      case .folder(let folder):
        subfolders.append(folder)
      case .file(let file):
        files.append(file)
      }
    }

    return MockFolderContent(files: files, subfolders: subfolders)
  }
}

struct MockFolderContent {
  let files: [MockFile]
  let subfolders: [MockFolder]
}

enum MockFolderItemPossibility {
  case folder(MockFolder)
  case file(MockFile)
}

protocol MockFolderItem {
  func mockFolderItemPossibility() -> MockFolderItemPossibility
}

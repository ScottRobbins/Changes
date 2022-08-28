struct WorkingFolderFinder {
  private let currentFolder: Folder

  init(currentFolder: Folder = DefaultFolder.current) {
    self.currentFolder = currentFolder
  }

  func getWorkingFolder() throws -> Folder {
    var _folder: Folder? = currentFolder
    while let folder = _folder {
      defer { _folder = folder.getParentFolder() }

      if let _ = try? folder.subfolder(named: ".changes") {
        return folder
      }
    }

    throw WorkingFolderFinderError.missing("No working folder found.")
  }
}

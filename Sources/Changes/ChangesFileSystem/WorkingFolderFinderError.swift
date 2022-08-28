enum WorkingFolderFinderError: Error, CustomStringConvertible {
  case missing(String)

  public var description: String {
    switch self {
    case .missing(let message):
      return message
    }
  }
}

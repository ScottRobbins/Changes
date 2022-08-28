enum ConfigurationLoadError: Error, CustomStringConvertible {
  case invalidFormat(String)
  case missing(String)
  case fileReadError(String)

  public var description: String {
    switch self {
    case .invalidFormat(let message),
      .missing(let message),
      .fileReadError(let message):
      return message
    }
  }
}

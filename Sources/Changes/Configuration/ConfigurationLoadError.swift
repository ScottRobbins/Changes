enum ConfigurationLoadError: Error, CustomStringConvertible {
  case invalidFormat(String)
  case missing(String)

  public var description: String {
    switch self {
    case .invalidFormat(let message),
      .missing(let message):
      return message
    }
  }
}

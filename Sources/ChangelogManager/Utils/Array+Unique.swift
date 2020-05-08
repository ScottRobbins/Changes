extension Array where Element: Hashable {
  func uniqueValues() -> [Element] {
    var set = Set<Element>()
    var newArray = [Element]()
    for value in self {
      if !set.contains(value) {
        set.insert(value)
        newArray.append(value)
      }
    }
    return newArray
  }
}

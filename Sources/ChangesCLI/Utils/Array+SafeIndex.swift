extension Array {
  func element(atIndex index: Int) -> Element? {
    if index < self.count {
      return self[index]
    }
    else {
      return nil
    }
  }
}

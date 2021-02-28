import Version

protocol ContainsVersionProtocol {
  func contains(_ element: Version) -> Bool
}

extension Array: ContainsVersionProtocol where Element == Version { }
extension ClosedRange: ContainsVersionProtocol where Bound == Version { }
extension PartialRangeFrom: ContainsVersionProtocol where Bound == Version { }
extension PartialRangeThrough: ContainsVersionProtocol where Bound == Version { }
extension PartialRangeUpTo: ContainsVersionProtocol where Bound == Version { }
extension Range: ContainsVersionProtocol where Bound == Version { }


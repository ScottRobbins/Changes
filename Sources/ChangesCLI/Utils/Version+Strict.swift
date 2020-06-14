import Version

extension Version {
  var release: Version {
    var mutableSelf = self
    mutableSelf.prerelease = nil
    mutableSelf.build = nil
    return mutableSelf
  }

  var isPrerelease: Bool {
    return self.prerelease != nil
  }

  var droppingBuildMetadata: Version {
    var mutableSelf = self
    mutableSelf.build = nil
    return mutableSelf
  }
}

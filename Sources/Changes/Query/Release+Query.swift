import Version

extension Release {
  public static func query() -> ReleaseQuery {
    ReleaseQuery(allowedReleases: nil) // this should call .all() and return the release
  }

  public static func query(releases: [Version]) -> ReleaseQuery {
    ReleaseQuery(allowedReleases: releases)
  }

  public static func query(releases: ClosedRange<Version>) -> ReleaseQuery {
    ReleaseQuery(allowedReleases: releases)
  }

  public static func query(releases: Range<Version>) -> ReleaseQuery {
    ReleaseQuery(allowedReleases: releases)
  }

  public static func query(releases: PartialRangeFrom<Version>) -> ReleaseQuery {
    ReleaseQuery(allowedReleases: releases)
  }

  public static func query(releases: PartialRangeUpTo<Version>) -> ReleaseQuery {
    ReleaseQuery(allowedReleases: releases)
  }

  public static func query(releases: PartialRangeThrough<Version>) -> ReleaseQuery {
    ReleaseQuery(allowedReleases: releases)
  }

  // Finish release query ability on query type func .all() will actually execute the query
  // Separate out the "release" type that gets returned to users from the one stored in the file if necessary
  // Figure out how to handle all of possibilities in CLI with special words like "latest" - add top level `.latest()` (maybe top level .first if needed)
  // Do I want the top-level query to specify releases or do I think I want a builder pattern for the future. Commit to one.
}
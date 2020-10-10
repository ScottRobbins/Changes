import ArgumentParser
import Files
import Version
import Yams

private struct ReleaseAndPrereleaseInfo {
  let release: ReleaseInfo
  let prereleases: [ReleaseInfo]
}

struct ReleaseQuerier {
  private let latest = "latest"

  func query(versions: [Version], includeLatest: Bool) throws -> [ReleaseQueryItem] {
    let releases = try fetchReleases()
    let explicitReleases = try explicitReleaseInfo(releases: releases, versions: versions)
    let _latestReleaseInfo = includeLatest ? try latestReleaseInfo(releases: releases) : nil

    let queriedReleases = explicitReleases + [_latestReleaseInfo].compactMap { $0 }
    return queriedReleases.map {
      let prereleaseQueryItems = $0.prereleases.map { prerelease in
        PrereleaseQueryItem(
          version: prerelease.version.description,
          createdAtDate: prerelease.createdAtDate
        )
      }.sorted { $0.version > $1.version }

      return ReleaseQueryItem(
        version: $0.release.version.description,
        createdAtDate: $0.release.createdAtDate,
        prereleases: prereleaseQueryItems
      )
    }
  }

  private func fetchReleases() throws -> [ReleaseAndPrereleaseInfo] {
    let loadedConfig = try ConfigurationLoader().load()
    guard let workingFolder = try File(path: loadedConfig.path).parent else {
      throw ChangesError("Could not find folder of changes config.")
    }

    return try workingFolder.createSubfolderIfNeeded(
      at: ".changes/releases"
    ).subfolders.map(releaseInfo(for:))
  }

  private func releaseInfo(for folder: Folder) throws -> ReleaseAndPrereleaseInfo {
    let releaseInfoString = try folder.file(named: "info.yml").readAsString()
    let decoder = YAMLDecoder()
    let release = try decoder.decode(ReleaseInfo.self, from: releaseInfoString)

    let prereleases: [ReleaseInfo] = try folder.subfolders.filter { Version.valid(string: $0.name) }
      .map {
        let prereleaseInfoString = try $0.file(named: "info.yml").readAsString()
        return try decoder.decode(ReleaseInfo.self, from: prereleaseInfoString)
      }

    return ReleaseAndPrereleaseInfo(release: release, prereleases: prereleases)
  }

  private func explicitReleaseInfo(
    releases: [ReleaseAndPrereleaseInfo],
    versions: [Version]
  ) throws -> [ReleaseAndPrereleaseInfo] {
    try versions
      .map { realVersion -> ReleaseAndPrereleaseInfo in
        let _matchedRelease = releases.first {
          $0.release.version == realVersion
        }
        guard let matchedRelease = _matchedRelease else {
          throw ValidationError(#"Version "\#(realVersion)" was not found"#)
        }

        return matchedRelease
      }
  }

  private func latestReleaseInfo(
    releases: [ReleaseAndPrereleaseInfo]
  ) throws -> ReleaseAndPrereleaseInfo? {
    return releases.sorted { $0.release.version > $1.release.version }.first
  }
}

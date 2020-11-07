# Changes

Changes is CLI tool (and in the future a framework) for creating Changelog entries and generating Changelogs and other documents from those.  

**Note:** This is still in early development. API is subject to breakage between minor versions below 1.0.0

1. [How does it work?](#how-does-it-work)
2. [Why build this tool?](#why-build-this-tool)
3. [Installation](#installation)
4. [Usage](#usage)

### How does it work? 

Changes entries are stored as JSON files, categorized by what releases they are a part of. These entries contain metadata, such as a message as well as one or more tags. 

Tags might include things you would want in a Changelog (Added, Removed, Fixed, etc), but you may have 
other tags for separate files (perhaps a "Release Note" tag, a tag to generate notes for QA, or a tag that denotes 
whether this change will require a major/minor/patch version bump). 

Changes can use these entries and releases to generate changelog files, and these changes and releases can also be queried.

### Why build this tool?

There are 2 main reasons:
1. Changelog files, when used in a team environment, have a tendency to create merge conflicts. These aren't difficult to resolve, but they are frequent and a hassle. 
2. Being able to add extra metadata to your changes that is easily queryable opens the door to further automation. This can be used to generate release notes, notes for QA, determine release version numbers and more. 

### Installation

The first thing you'll need to do is [install Swift](https://swift.org/download/#using-downloads).

After that is complete, install the binary via one of these methods:

##### Homebrew: 

```bash
$ brew install swiftbuildtools/formulae/changes
```

##### Swift Package Manager

Add this to your package.swift file
```swift
.package(url: "https://github.com/SwiftBuildTools/Changes.git", .exact("0.1.0"))
```

##### Install pre-built binaries

Pre-built binaries are uploaded as assets on Github releases for macOS and every linux version Swift officially 
supports (if any are missing please open an issue).

1. Download the needed binary

```bash
$ curl -OL https://github.com/SwiftBuildTools/Changes/releases/download/<version>/changes-swift-5-2-<target>.tar.gz
```

Or

```bash
$ wget https://github.com/SwiftBuildTools/Changes/releases/download/<version>/changes-swift-5-2-<target>.tar.gz
```

2. Unpackage the binary

```bash
$ tar -xvzf changes-swift-5-2-<target>.tar.gz 
```

Put this executable somewhere in your PATH.

### Usage

_Note: If you're using the Swift Package Manager installation method, prepend `swift run` to the commands_

Initialize your repository with a configuration file.
```bash
$ changes init
```

That will create a configuration file called `.changes.yml`. 

Add a changelog entry by following the CLI prompts.
```bash
$ changes add
```

It will then ask you this entry should be tagged with as well as a description of your Changelog entry.

You can also provide this information as arguments.
```bash
$ changes add --tags Added Minor --description "Added some new Ability!"
```
(You can also use the shortened arguments of `-t` and `-d`)

If you need to add an entry to an existing release, you can speicfy that as an argument.
```bash
$ changes add --release 1.0.0
```
(You can also use the shortened argument of `-r`)

If at any point in time you would like to regenerate your Changelog:
```bash
$ changes regenerate
```

If you want to create a release

```bash
$ changes release 1.0.0
```

The tool also understands pre-release versions. For example: 
```bash
$ changes release 1.0.0-alpha.1
```

Examples of querying for releases:

```bash
$ changes releases 1.0.0 1.1.0 latest
$ changes releases --start 1.0.0 --end 1.1.0
$ changes releases --start 1.1.0
```

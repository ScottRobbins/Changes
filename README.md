# Changes

Changes is CLI tool (and in the future a framework) for creating Changelog entries and generating Changelogs and other documents from those.  

**Note:** This is still in early development.

### How does it work? 

When you run the CLI tool, it will create a "Changelog Entry", which is a YAML file containing the description 
of your entry, when it was added and what to tag the entry as. It will then use these YAML files to 
generate / regenerate your changelog.

Tags might include things you would want in a Changelog (Added, Removed, Fixed, etc), but you may have 
other tags for separate files (perhaps a "Release Note" tag, a tag to generate notes for QA, or a tag that denotes 
whether this change will require a major/minor/patch version bump). 

You can define multiple files that all get generated with whatever tags they should understand.

### Getting Started

Add this to your package.swift file.
```swift
.package(url: "https://github.com/SwiftBuildTools/Changes.git", branch: "master")
```

Initialize your repository with a configuration file.
```bash
$ swift run changes init
```

That will create a configuration file called `.changes.yml`. 

Add a changelog entry by following the CLI prompts.
```bash
$ swift run changes add
```

It will then ask you this entry should be tagged with as well as a description of your Changelog entry.

You can also provide this information as arguments.
```bash
$ swift run changes add --tags Added Minor --description "Added some new Ability!"
```
(You can also use the shortened arguments of `-t` and `-d`)

If you need to add an entry to an existing release, you can speicfy that as an argument.
```bash
$ swift run changes add --release 1.0.0
```
(You can also use the shortened argument of `-r`)

If at any point in time you would like to regenerate your Changelog:
```bash
$ swift run changes regenerate
```

If you want to create a release

```bash
$ swift run changes release 1.0.0
```

The tool also understands pre-release versions. For example: 
```bash
$ swift run changes release 1.0.0-alpha.1
```
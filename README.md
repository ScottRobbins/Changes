# ChangelogManager

ChangelogManager is CLI tool (and in the future a framework) for creating Changelog entries and generating Changelogs and other documents from those.  

**Note:** This is still in early development.

### How does it work? 

When you run the CLI tool, it will create a "Changelog Entry", which is a YAML file containing the description 
of your entry, when it was added and what to tag the entry as. It will then use these YAML files to 
generate / regenerate your changelog.

Tags might include things you would want in a Changelog (Added, Removed, Fixed, etc), but you may have 
other tags for separate files (perhaps a "Release Note" tag, or a tag to generate notes for QA). 
You can define multiple files that all get generated with whatever tags they should understand.

### Getting Started

Add this to your package.swift file.
```swift
.package(url: "https://github.com/SwiftBuildTools/ChangelogManager.git", branch: "master")
```

Initialize your repository with a configuration file.
```bash
$ swift run changelog init
```

That will create a configuration file called `.changelog-manager.yml`. 

Add a changelog entry by following the CLI prompts.
```bash
$ swift run changelog add
```

It will then ask you for the tag this entry should be under as well as a description of your Changelog entry.

You can also provide this information as arguments.
```bash
$ swift run changelog add --tag Added --description "Added my first Changelog entry!"
```
(You can also use the shortened arguments of `-t` and `-d`)

If you need to add an entry to an existing release*, you can speicfy that as an argument.
```bash
$ swift run changelog add --release 1.0.0
```
(You can also use the shortened argument of `-r`)

*Creating new releases has not yet been built

If at any point in time you would like to regenerate your Changelog:
```bash
$ swift run changelog regenerate
```

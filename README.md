# ChangelogManager

ChangelogManager is CLI tool (and in the future a framework) for creating Changelog entries and generating Changelogs and other documents from those.  

**Note:** This is still in early development.

### How does it work? 

When you run the CLI tool, it will create a "Changelog Entry", which is a YAML file containing the description 
of your entry, when it was added and what category of an entry it is. It will then use these YAML files to 
generate / regenerate your changelog.

Categories might include things you would want in a Changelog (Added, Removed, Fixed, etc), but you may have 
other categories for separate files (perhaps a "Release Note" category, or a category to generate notes for QA). 
You can define multiple files that all get generated with whatever categories they should understand.

### Getting Started

Add this to your package.swift file.
```swift
.package(url: "https://github.com/SwiftBuildTools/ChangelogManager.git", branch: "master")
```

Initialize your repository with a configuration file.
```bash
$ swift run changelog-manager init
```

That will create a configuration file called `.changelog-manager.yml`. 

Add a changelog entry by following the CLI prompts.
```bash
$ swift run changelog-manager add
```

It will then ask you for the category this entry should be under as well as a description of your Changelog entry.

You can also provide this information as arguments.
```bash
$ swift run changelog-manager add --category Added --description "Added my first Changelog entry!"
```

If you need to add an entry to an existing release*, you can speicfy that as an argument.
```bash
$ swift run changelog-manager add --release 1.0.0
```

*Creating new releases has not yet been built

If at any point in time you would like to regenerate your Changelog:
```bash
$ swift run changelog-manager regenerate
```
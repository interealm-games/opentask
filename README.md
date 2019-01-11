# opentask

haxe -cp common/src -main interealmGames.common.Test --interp

The goal is to create a command line task runner executable that is platform / language independent 
for language-ambiguous projects, lesser-used languages that do not have a robust tool set or more 
general projects.

## Use Cases

- Working with languages that do not have robust task runners / package managers like NPM or Composer
- Projects with multiple languages
- Projects with complex build sequences usually handled by IDE or other (ie. place all build needs in repo).

## Usage

See the configuration examples in `/schemas/examples` to create a configuration.

Place the OpenTask executables from the release into your repo or install on your computer (and add them to the PATH var). The executables are small should be okay to add to a repo, usually in their own folder with a shortcut/symlink to the correct executable for your system.

```
opentask --help
opentask run [task name]
```

## Specifications

Schemas written in [Json Schema](https://json-schema.org/) in the `/schemas` folder.

haxe -cp src -cp common/src -neko ./bin/opentask.n -main interealmGames.opentask.Main
nekotools boot bin/opentask.n

## Testing

Currently only have testing for dependencies. Need to build tests for this project.

```
haxe -cp common/src -main interealmGames.common.Test --interp
```
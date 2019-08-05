# opentask

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


## Build

You can build an executable from scratch:

```bash
haxe -cp src -cp common/src --cpp bin/cpp -main interealmGames.opentask.Main
```
This will yield the executable `bin/cpp/Main.exe` (or your platform equivalent)

If you download a release of *opentask* for you system and make it available from the repo root, you can run:
```bash
opentask requirements test # checks if you have all required tools installed (cp fails for Windows :( )
opentask rungroup init # first time only (gets submodules and haxelibs)
opentask rungroup build
```
Which will create an executable at `bin/opentask.exe`  (or your platform equivalent)

Using *opentask* to build *opentask*, FTW!

**Note**: If you are building on Haxe 3.4.7 or lower, you will need to change the build command to use `-cpp` instead of `--cpp`. Otherwise, this library should work in Haxe 3 or 4 just fine.

## Testing

Currently only have testing for dependencies. Need to build tests for this project.

```
haxe -cp common/src -main interealmGames.common.Test --interp
```

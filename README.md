# opentask

haxe -cp common/src -main interealmGames.common.Test --interp

The goal is to create a command line task runner executable that is platform / language independent 
for language-ambiguous projects, lesser used languages that do not have a robust tool set or more 
general projects.

## Specifications

I would like to use the [tasks.json](https://code.visualstudio.com/docs/editor/tasks-appendix) specification as much as possible because it is well-designed as well as language/platform agnostic.

A few tweaks will need to be made to accomplish a few other goals.

 - Program requirements (which executables or tools will need to be installed, including versions)
 - Global command analogs for various platforms
 - A secondary file with paths for specific commands, so a user can target a specific version of a tool on their system rather than the global.

Schemas will be written in [Json Schema](https://json-schema.org/)



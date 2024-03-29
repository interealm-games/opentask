package interealmGames.opentask;

using interealmGames.common.StringToolsExtension;

import haxe.io.Path;

/**
 * Manages display of Help messages
 */
class Help
{
	static private var HELP_TEXT = "
Usage: %s [-h | --help] [-v | --version] [[ -d | --config-dir =<path>] | [-c | --config=<path>] [-l | --config-local=<path>]] <command> [<args>]

General Options:
  -h,--help: Displays program information
  -v, --version: Displays the program version information
  -d, --config-dir: Directory where the opentask.json [and possibly opentask.local.json] configuration file(s) are located. Cannot be used with '-c' and '-l'.
  -c, --config: File path to the configuration file, including file name. Cannot be used with '-d'.
  -l, --config - local: File path to the local configuration file, including file name. Cannot be used with '-d'.

Commands:
  list
    Lists the names and descriptions of all available tasks.

  requirements [list | test]
    'list' shows all programs needed for the tasks. 'test' verifies that all the programs are installed and available.

  run <task-name>
    Runs the command for the named task.
    Additional arguments can be passed to the task
    by placing them after a ' -- ' after the task name.

  rungroup [-f | --force] <group-name>
    Runs the commands for all tasks in the group, in the order of their ranking. Tied rankings are run in their order in the configuration file. The group will stop running if any task fails (with exit code > 0) unless the 'force' option is applied.

For information on the configuration files, go to: https://github.com/interealm-games/opentask
";

	static public function display() {
		var path = new Path(Sys.programPath());
		var executableName = path.file;

		// In Neko, the filename is missing => https://github.com/HaxeFoundation/haxe/issues/5708
		if (executableName.length == 0) {
			executableName = 'opentask';
		}
		var helpText = StringTools.format(Help.HELP_TEXT, [executableName]);
		Sys.println(helpText); // Sys not Log
	}
}

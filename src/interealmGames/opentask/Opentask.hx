package interealmGames.opentask;

import sys.FileSystem;
import haxe.io.Path;
import interealmGames.common.commandLine.OptionSet;
import interealmGames.opentask.errors.FileDoesNotExistError;
import interealmGames.opentask.errors.GroupDoesNotExistError;
import interealmGames.opentask.errors.InvalidCommandError;
import interealmGames.opentask.errors.InvalidConfigurationError;
import interealmGames.opentask.errors.InvalidLocalConfigurationError;
import interealmGames.opentask.errors.MissingArgumentError;
import interealmGames.opentask.errors.MissingCommandError;
import interealmGames.opentask.errors.TaskDoesNotExistError;
import interealmGames.opentask.errors.TaskFailedError;
import interealmGames.common.commandLine.CommandLine;
import interealmGames.common.commandLine.CommandLineValues;
import interealmGames.opentask.Configuration;
import interealmGames.opentask.errors.JsonParsingError;
import interealmGames.opentask.errors.BaseError;
import interealmGames.opentask.Help;
import interealmGames.opentask.Platform;
import interealmGames.opentask.ProgramInformation;
import interealmGames.opentask.Log;

/**
 * The program logic
 */
class Opentask
{
	/**
	 * Current Application Version
	 */
	static public var VERSION = "0.4.1";

	/**
	 * The currently loaded task configuration
	 */
	var configuration:Configuration;

	/**
	 * The currently loaded local task configuration
	 */
	var localConfiguration:Null<LocalConfiguration> = null;

	var platform:Platform;

	public function new(
		platform:Platform,
		configuration:Configuration,
		?localConfiguration:LocalConfiguration
	) {
		this.platform = platform;
		this.configuration = configuration;
		this.localConfiguration = localConfiguration;
	}

	/**
	 * Lists all tasks available in the configuration
	 * @param	configPath The file location of the configuration.
	 * @return Void
	 */
	public function list(configPath:String):Void {
		if(this.configuration.countTasks() > 0) {
			Log.printLine("Available Tasks:");
			Log.printLine("----------------");
			for (task in this.configuration.tasks()) {
				var line = task.name;
				if (task.description.length > 0) {
					line += ": " + task.description;
				}
				Log.printLine(line);
			}

			Log.printLine();
			Log.printLine("Available Groups (Group Name -> Tasks):");
			Log.printLine("---------------------------------------");
			for (groupName in this.configuration.groupNames()) {
				var line = groupName + ": ";
				var taskNames = this.configuration.groups().get(groupName).map(function(task:Task) {
					return task.name;
				});
				line += taskNames.join(', ');

				Log.printLine(line);
			}
		} else {
			Log.warning("No tasks in configurations");
		}

		Log.printLine();
		Log.printLine('At $configPath');
	}

	/**
	 * Runs a command from the Configuration
	 * @param	taskName Name of the Task
	 * @throws	TaskDoesNotExistError
	 * @return Int The return value of the run command
	 */
	public function run(taskName:String, passOnArguments:String = ''):Int {
		var task = this.configuration.getTask(taskName);

		if (task == null) {
			throw new TaskDoesNotExistError(taskName);
		}

		Log.printLine('Running Task: $taskName');
		Log.printLine('-------------------------');

		var currentCwd = Sys.getCwd();
		var cwd = task.resolveCwd(this.platform);

		if(cwd != null) {
			Log.printLine('Set Working Directory: $cwd');
			Sys.setCwd(cwd);
		}

		var command = this.configuration.resolveCommand(this.platform, task.command, localConfiguration);
		var arguments = task.resolveArguments(this.platform);

		var line = command + ' ' + arguments.join(' ') + ' ' + passOnArguments;
		Log.printLine('Running Command: $line');
		var output = Sys.command(line);

		if(cwd != null) {
			Log.printLine('Reset Working Directory: $cwd');
			Sys.setCwd(currentCwd);
		}

		return output;
	}

	/**
	 * Runs a group of tasks
	 * @param	groupName The name of the group of Tasks
	 * @param	force Continue running if any step fails
	 * @throws	GroupDoesNotExistError
	 * @returns Void
	 */
	public function runGroup(
		groupName:String,
		force:Bool
	):Void {
		var groups = this.configuration.groups();

		if (!groups.exists(groupName)) {
			throw new GroupDoesNotExistError(groupName);
		}

		var tasks = groups.get(groupName);
		Log.printLine('-------------------------');
		Log.printLine('Running Group: $groupName');
		Log.printLine('-------------------------');
		Log.printLine('');

		for (task in tasks) {
			var output = this.run(task.name);
			if (output > 0) {
				Log.printLine('-------------------------');
				Log.printLine('Error in Task: ${task.name}');

				if (!force) {
					Log.printLine('Stopping Group');
					throw new TaskFailedError(task.name, output);
				}
				Log.printLine('-------------------------');
			}
		}
	}

	/**
	 * Displays the programs required by the configuration
	 */
	public function showRequirements():Void {
		if(this.configuration.countRequirements() > 0) {
			Log.printLine("Required Programs:");
			Log.printLine("------------------");
			for (requirement in this.configuration.requirements()) {
				Log.printLine(requirement.name);
				var command = configuration.resolveCommand(this.platform, requirement.command, this.localConfiguration);
				var commandLabel = "Command" + (command == requirement.command ? "" : " (localized)") + ": ";

				Log.printLine("\t" + commandLabel + command);
				Log.printLine("\tVersion: " + (requirement.version.length > 0 ? requirement.version : "(not specified)"));

				Log.printLine();
			}
		} else {
			Log.warning("No required programs in configurations");
		}
	}

	/**
	 * Checks if all necessary programs are installed
	 */
	public function testRequirements():Void {
		if(this.configuration.countRequirements() > 0) {
			Log.printLine("Testing Requirements:");
			Log.printLine("---------------------");
			for (requirement in this.configuration.requirements()) {
				Log.printStart("Testing: " + requirement.name + "...");
				var args = this.configuration.resolveRequirementTest(this.platform, requirement.command, this.localConfiguration);

				var exitCode = 1;
				try {
					var process = new sys.io.Process(args[0], args.slice(1));
					exitCode = process.exitCode(true);
				} catch (e:Any) {

				}
				Log.printEnd(exitCode == 0 ? 'installed.' : 'NOT FOUND!');
			}
		} else {
			Log.warning("No required programs in configurations");
		}
	}
}

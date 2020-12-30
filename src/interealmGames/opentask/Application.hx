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
import interealmGames.opentask.ProgramInformation;
import interealmGames.opentask.Log;

/**
 * The program logic
 */
class Application 
{
	/**
	 * Command line arguments for various actions
	 */
	static public var COMMAND_LIST = "list";
	static public var COMMAND_REQUIREMENTS = "requirements";
	static public var COMMAND_REQUIREMENTS_LIST = "list";
	static public var COMMAND_REQUIREMENTS_TEST = "test";
	static public var COMMAND_RUN = "run";
	static public var COMMAND_RUN_GROUP = "rungroup";
	
	/**
	 * Command line options
	 */
	static public var OPTION_HELP = "help";
	static public var OPTION_HELP_SHORT = "h";
	static public var OPTION_FORCE = "force";
	static public var OPTION_FORCE_SHORT = "f";
	static public var OPTION_VERSION = "version";
	static public var OPTION_VERSION_SHORT = "v";
	
	/**
	 * Current Application Version
	 */
	static public var VERSION = "0.2.0";
	
	/**
	 * The currently loaded task configuration
	 */
	var configuration:Configuration;
	/**
	 * Default path and filename to look for configurations
	 */
	var configurationFilePath:String = "opentask.json";
	
	/**
	 * The currently loaded local task configuration
	 */
	var localConfiguration:Null<LocalConfiguration> = null;
	/**
	 * Default path and filename to look for local configurations
	 */
	var localConfigurationFilePath:Null<String> = "opentask.local.json";
	
	public function new() 
	{
		try {
			var commandLineValues: CommandLineValues = CommandLine.process(
				[Application.OPTION_FORCE],
				[Application.OPTION_FORCE_SHORT]
			);
			var options = commandLineValues.options;
			var arguments = commandLineValues.arguments;
			
			
			if (options.hasShortOption(Application.OPTION_HELP_SHORT) || options.hasLongOption(Application.OPTION_HELP)) {
				Help.display();
				this.end();
			}
			
			if (options.hasShortOption(Application.OPTION_VERSION_SHORT) || options.hasLongOption(Application.OPTION_VERSION)) {
				ProgramInformation.display();
				this.end();
			}
			
			
			this.setConfigurationPaths(options);
			this.configuration = this.loadConfiguration(this.configurationFilePath);
			
			if (FileSystem.exists(this.localConfigurationFilePath)) {
				this.localConfiguration = this.loadLocalConfiguration(this.localConfigurationFilePath);
			}
			
			//arguments[0] is the OpenTask application
			if (arguments.length < 2) {
				throw new MissingCommandError();
			}
			
			var validCommands:Array<String> = [
				Application.COMMAND_LIST,
				Application.COMMAND_REQUIREMENTS,
				Application.COMMAND_RUN,
				Application.COMMAND_RUN_GROUP
			];
			
			
			var command = arguments[1];
			
			if (validCommands.indexOf(command) == -1) {
				throw new InvalidCommandError(command);
			}
			
			
			if (command == Application.COMMAND_LIST) {
				this.list(this.configuration, this.configurationFilePath);
			} else if (command == Application.COMMAND_REQUIREMENTS) {
				if (arguments.length < 3) {
					throw new MissingCommandError();
				}
				this.requirements(arguments[2], this.configuration, this.localConfiguration);
			} else if (command == Application.COMMAND_RUN) {
				if (arguments.length < 3) {
					throw new MissingArgumentError('Task Name');
				}
				this.run(arguments[2], this.configuration, this.localConfiguration);
			} else if (command == Application.COMMAND_RUN_GROUP) {
				if (arguments.length < 3) {
					throw new MissingArgumentError('Group Name');
				}

				var force = options.hasShortOption(Application.OPTION_FORCE_SHORT)
					|| options.hasLongOption(Application.OPTION_FORCE);

				this.runGroup(
					arguments[2],
					this.configuration,
					this.localConfiguration,
					force
				);
			}
		} catch (e:BaseError) {
			this.end(e);
		}
	}
	
	/**
	 * Terminates the application gracefully. Any errors that occur are properly displayed and 
	 * various helpful responses can be displayed.
	 * @param	error Optional error
	 */
	public function end(?error:BaseError):Void {
		if (error != null) {
			Sys.println(error.toString());
			
			if (Std.is(error, MissingCommandError) || Std.is(error, InvalidCommandError)) {
				Help.display();
			}
			
			if (
				Std.is(error, TaskDoesNotExistError) 
					|| Std.is(error, GroupDoesNotExistError) 
					|| Std.is(error, MissingArgumentError)
			) {
				this.list(this.configuration, this.configurationFilePath);
			}
		}
		
		Sys.exit(error != null ? 1 : 0);
	}
	
	/**
	 * Lists all tasks available in the configuration
	 * @param	configuration The application's configuration
	 * @param	taskPath The file location of the configuration.
	 */
	public function list(configuration:Configuration, taskPath:String):Void {
		if(configuration.countTasks() > 0) {
			Log.printLine("Available Tasks:");
			Log.printLine("----------------");
			for (task in configuration.tasks()) {
				var line = task.name;
				if (task.description.length > 0) {
					line += ": " + task.description;
				}
				Log.printLine(line);
			}
			
			Log.printLine();
			Log.printLine("Available Groups (Group Name -> Tasks):");
			Log.printLine("---------------------------------------");
			for (groupName in configuration.groups().keys()) {
				var line = groupName + ": ";
				var taskNames = configuration.groups().get(groupName).map(function(task:Task) {
					return task.name;
				});
				line += taskNames.join(', ');
				
				Log.printLine(line);
			}
		} else {
			Log.warning("No tasks in configurations");
		}
		
		Log.printLine();
		Log.printLine('At $taskPath');
	}
	
	/**
	 * Fetches the configuration file and creates a Configuration instance for the application
	 * @param	configurationFilePath The location of the configuration file.
	 * @return	The Configuration instance
	 * @throws	InvalidConfigurationError
	 */
	public function loadConfiguration(configurationFilePath:String):Configuration {
		var configuration:Configuration;
		try {
			var configurationObject:ConfigurationObject = cast this.loadJsonFile(configurationFilePath);
			configuration = new Configuration(configurationObject);
		} catch (e:BaseError) {
			var error = new InvalidConfigurationError(configurationFilePath);
			error.causedBy(e);
			throw error;
		}
		
		return configuration;
	}
	
	/**
	 * Fetches the contents of a JSON file and returns them as an object
	 * @param	path The location of the JSON file.
	 * @return	Dynamic Object with the contents.
	 * @throws	JsonParsingError
	 */
	public function loadJsonFile(path:String):Null<Dynamic> {
		var content:String = sys.io.File.getContent(path);
		
		var object = null;
		try {
			object = haxe.Json.parse(content);
		} catch (e:Any) {
			throw new JsonParsingError(path, e);
		}
		
		return object;
	}
	
	/**
	 * Fetches the local configuration file, if it exists, and creates a LocalConfiguration instance for the application
	 * @param	localConfigurationFilePath The location of the local configuration file.
	 * @return	The LocalConfiguration instance
	 * @throws	InvalidLocalConfigurationError
	 */
	public function loadLocalConfiguration(localConfigurationFilePath:String):LocalConfiguration {
		// find configuration file
		var localConfiguration:LocalConfiguration;
		try{
			var localConfigurationObject:LocalConfigurationObject = cast this.loadJsonFile(localConfigurationFilePath);
			localConfiguration = new LocalConfiguration(localConfigurationObject);
		} catch (e:BaseError) {
			var error = new InvalidLocalConfigurationError(configurationFilePath);
			error.causedBy(e);
			throw error;
		}
		
		return localConfiguration;
	}
	
	/**
	 * Handles all application tasks under the 'requirements' command.
	 * @param	command The sub-command
	 * @param	configuration The application's configuration
	 * @param	localConfiguration [OPTIONAL] The application's local configurations, if it exists
	 * @throws	InvalidCommandError
	 */
	public function requirements(command:String, configuration:Configuration, localConfiguration:Null<LocalConfiguration>):Void {
		var validCommands:Array<String> = [
			Application.COMMAND_REQUIREMENTS_LIST,
			Application.COMMAND_REQUIREMENTS_TEST
		];
		
		if (validCommands.indexOf(command) == -1) {
			throw new InvalidCommandError(command);
		}
		
		if (command == Application.COMMAND_REQUIREMENTS_LIST) {
			this.showRequirements(configuration, localConfiguration);
		} else if (command == Application.COMMAND_REQUIREMENTS_TEST) {
			this.testRequirements(configuration, localConfiguration);
		}
	}
	
	/**
	 * Runs a command from the Configuration
	 * @param	taskName Name of the Task
	 * @param	configuration The application's configuration
	 * @param	localConfiguration [OPTIONAL] The application's local configurations, if it exists
	 * @throws	TaskDoesNotExistError
	 */
	public function run(taskName:String, configuration:Configuration, localConfiguration:Null<LocalConfiguration>):Int {
		var task = configuration.getTask(taskName);
		
		if (task == null) {
			throw new TaskDoesNotExistError(taskName);
		}
		
		Log.printLine('Running Task: $taskName');
		Log.printLine('-------------------------');
		
		var currentCwd = Sys.getCwd();
		var cwd = task.resolveCwd();
		
		if(cwd != null) {
			Log.printLine('Set Working Directory: $cwd');
			Sys.setCwd(cwd);
		}
		
		var command = configuration.resolveCommand(task.command, localConfiguration);
		var arguments = task.resolveArguments();
		
		var line = command + ' ' + arguments.join(' ');
		Log.printLine('Running Command: $line');
		var output = Sys.command(command, arguments);
		
		if(cwd != null) {
			Log.printLine('Reset Working Directory: $cwd');
			Sys.setCwd(currentCwd);
		}

		return output;
	}
	
	/**
	 * Runs a group of tasks
	 * @param	groupName The name of the group of Tasks
	 * @param	configuration The application's configuration
	 * @param	localConfiguration [OPTIONAL] The application's local configurations, if it exists
	 * @throws	GroupDoesNotExistError
	 */
	public function runGroup(
		groupName:String,
		configuration:Configuration,
		localConfiguration:Null<LocalConfiguration>,
		force:Bool
	):Void {
		var groups = configuration.groups();
		
		if (!groups.exists(groupName)) {
			throw new GroupDoesNotExistError(groupName);
		}

		var tasks = groups.get(groupName);
		Log.printLine('-------------------------');
		Log.printLine('Running Group: $groupName');
		Log.printLine('-------------------------');
		Log.printLine('');
		
		for (task in tasks) {
			var output = this.run(task.name, configuration, localConfiguration);
			if (output > 0) {
				Log.printLine('-------------------------');
				Log.printLine('Error in Task: ${task.name}');

				if (!force) {
					Log.printLine('Stopping Group');
					this.end(new TaskFailedError(task.name, output));
				}
				Log.printLine('-------------------------');
			}
		}
	}
	
	/**
	 * Analyzes the given options and determines the user's preferred configuration paths
	 * @param	options The options from the command line.
	 */
	public function setConfigurationPaths(options:OptionSet):Void {
		if (options.hasShortOption('d') || options.hasLongOption('config-dir')) {
			var path = '';
			
			if (options.hasShortOption('d') && options.getShortValues('d').length > 0) {
				path = options.getShortValues('d')[0];
			} else if (options.hasLongOption('config-dir') && options.getLongValues('config-dir').length > 0) {
				path = options.getLongValues('config-dir')[0];
			}
			
			if (path != '') {
				// Path.addTrailingSlash will add a slash to a blank string
				path = haxe.io.Path.addTrailingSlash(path);
				this.configurationFilePath = path + configurationFilePath;
				this.localConfigurationFilePath = path + localConfigurationFilePath;
			}
		} else {
			if (options.hasShortOption('c') || options.hasLongOption('config')) {
				var path = '';
				
				if (options.hasShortOption('c') && options.getShortValues('c').length > 0) {
					path = options.getShortValues('c')[0];
				} else if (options.hasLongOption('config') && options.getLongValues('config').length > 0) {
					path = options.getLongValues('config')[0];
				}

				this.configurationFilePath = path;
			}
			
			if (options.hasShortOption('l') || options.hasLongOption('config-local')) {
				var path = '';
				
				if (options.hasShortOption('l') && options.getShortValues('l').length > 0) {
					path = options.getShortValues('l')[0];
				} else if (options.hasLongOption('config-local') && options.getLongValues('config-local').length > 0) {
					path = options.getLongValues('config-local')[0];
				}
				
				if (path != '') {
					//Path.addTrailingSlash will add a slash to a blank string
					path = haxe.io.Path.addTrailingSlash(path);
					this.localConfigurationFilePath = path + localConfigurationFilePath;
				}
				
				if (!FileSystem.exists(this.localConfigurationFilePath)) {
					throw new FileDoesNotExistError(this.localConfigurationFilePath);
				}
			}
		}
		
		if (!FileSystem.exists(this.configurationFilePath)) {
			throw new FileDoesNotExistError(this.configurationFilePath);
		}
	}
	
	/**
	 * Displays the programs required by the configuration
	 * @param	configuration The application's configuration
	 * @param	localConfiguration [OPTIONAL] The application's local configurations, if it exists
	 */
	public function showRequirements(configuration:Configuration, localConfiguration:Null<LocalConfiguration>):Void {
		if(configuration.countRequirements() > 0) {
			Log.printLine("Required Programs:");
			Log.printLine("------------------");
			for (requirement in configuration.requirements()) {
				Log.printLine(requirement.name);
				var command = configuration.resolveCommand(requirement.command, localConfiguration);
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
	 * @param	configuration The application's configuration
	 * @param	localConfiguration [OPTIONAL] The application's local configurations, if it exists
	 */
	public function testRequirements(configuration:Configuration, localConfiguration:Null<LocalConfiguration>):Void {
		if(configuration.countRequirements() > 0) {
			Log.printLine("Testing Requirements:");
			Log.printLine("---------------------");
			for (requirement in configuration.requirements()) {
				Log.printStart("Testing: " + requirement.name + "...");
				var command = configuration.resolveCommand(requirement.command, localConfiguration);
				var testArgument = requirement.resolveTestArgument();
				
				var exitCode = 1;
				try {
					var process = new sys.io.Process(command, [testArgument]);
					exitCode = process.exitCode(true);
				}catch (e:Any) {
					
				}
				Log.printEnd(exitCode == 0 ? 'installed.' : 'NOT FOUND!');
			}
		} else {
			Log.warning("No required programs in configurations");
		}	
	}
}

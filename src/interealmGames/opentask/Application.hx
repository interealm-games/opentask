package interealmGames.opentask;

import interealmGames.opentask.Opentask;
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
	static public var VERSION = "0.4.0";

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

	var opentask:Opentask;

	var platform:Platform;

	public function new() {}

	public function run()
	{
		try {
			this.platform = PlatformTools.resolvePlatform();
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


			this.opentask = new Opentask(
				this.platform,
				this.configuration,
				this.localConfiguration
			);
			if (command == Application.COMMAND_LIST) {
				this.opentask.list(this.configurationFilePath);
			} else if (command == Application.COMMAND_REQUIREMENTS) {
				if (arguments.length < 3) {
					throw new MissingCommandError();
				}
				this.requirements(arguments[2]);
			} else if (command == Application.COMMAND_RUN) {
				if (arguments.length < 3) {
					throw new MissingArgumentError('Task Name');
				}

				this.opentask.run(arguments[2], CommandLine.getCommand().split(' -- ')[1]);
			} else if (command == Application.COMMAND_RUN_GROUP) {
				if (arguments.length < 3) {
					throw new MissingArgumentError('Group Name');
				}

				var force = options.hasShortOption(Application.OPTION_FORCE_SHORT)
					|| options.hasLongOption(Application.OPTION_FORCE);

				this.opentask.runGroup(
					arguments[2],
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
				this.opentask.list(this.configurationFilePath);
			}
		}

		Sys.exit(error != null ? 1 : 0);
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
	 * @throws	InvalidCommandError
	 */
	public function requirements(command:String):Void {
		var validCommands:Array<String> = [
			Application.COMMAND_REQUIREMENTS_LIST,
			Application.COMMAND_REQUIREMENTS_TEST
		];

		if (validCommands.indexOf(command) == -1) {
			throw new InvalidCommandError(command);
		}

		if (command == Application.COMMAND_REQUIREMENTS_LIST) {
			this.opentask.showRequirements();
		} else if (command == Application.COMMAND_REQUIREMENTS_TEST) {
			this.opentask.testRequirements();
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
}

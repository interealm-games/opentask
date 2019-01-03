package interealmGames.opentask;

using interealmGames.common.fileSystem.FileSystemExtension;

import haxe.io.Output;
import haxe.io.Path;
import interealmGames.common.commandLine.OptionSet;
import interealmGames.opentask.errors.FileDoesNotExistsError;
import interealmGames.opentask.errors.GroupDoesNotExistError;
import interealmGames.opentask.errors.InvalidCommandError;
import interealmGames.opentask.errors.InvalidConfigurationError;
import interealmGames.opentask.errors.InvalidLocalConfigurationError;
import interealmGames.opentask.errors.MissingArgumentError;
import interealmGames.opentask.errors.MissingCommandError;
import interealmGames.opentask.errors.TaskDoesNotExistError;
import sys.FileSystem;
import interealmGames.common.commandLine.CommandLine;
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
	static public var COMMAND_LIST = "list";
	static public var COMMAND_REQUIREMENTS = "requirements";
	static public var COMMAND_REQUIREMENTS_LIST = "list";
	static public var COMMAND_REQUIREMENTS_TEST = "test";
	static public var COMMAND_RUN = "run";
	static public var COMMAND_RUN_GROUP = "rungroup";
	
	static public var OPTION_HELP = "help";
	
	static public var VERSION = "0.1.0";
	
	var configuration:Configuration;
	var configurationFilePath:String = "opentask.json";
	
	var localConfiguration:Null<LocalConfiguration> = null;
	var localConfigurationFilePath:Null<String> = "opentask.local.json";
	
	public function new() 
	{
		try {
			var options = CommandLine.getOptions();
			//trace(options);
			
			var arguments = CommandLine.getArguments();
			//trace(arguments);
			
			
			if (options.hasShortOption('h') || options.hasLongOption('help')) {
				Help.display();
				this.end();
			}
			
			if (options.hasShortOption('v') || options.hasLongOption('version')) {
				ProgramInformation.display();
				this.end();
			}
			
			
			this.setConfigurationPaths(options);
			this.configuration = this.loadConfiguration(this.configurationFilePath);
			
			if (!FileSystem.exists(this.localConfigurationFilePath)) {
				localConfiguration = this.loadLocalConfiguration(this.localConfigurationFilePath);
			}
			
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
				this.runGroup(arguments[2], this.configuration, this.localConfiguration);
			}
			
			
			
			/*
			var paths = FileSystem.recursiveLoop(
				"C:/www/interealm-games/editor-frontend/browser/src/interealmGames/browser/components", 
				"scss"
			);
			for (path in paths) {
				trace(path);
			}
			
			//then validate the configuration
			// ...
			
			trace(configuration);
			trace(localConfiguration);
			
			trace(Sys.systemName()); //Windows
			//*/
		} catch (e:BaseError) {
			this.end(e);
		}
		
		// this.end();
	}
	
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
	
	public function loadConfiguration(configurationFilePath:String):Null<Configuration> {
		// find configuration file
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
	
	public function loadLocalConfiguration(localConfigurationFilePath:String):Null<LocalConfiguration> {
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
	
	public function run(taskName:String, configuration:Configuration, localConfiguration:Null<LocalConfiguration>):Void {
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
		Sys.command(command, arguments);
		
		if(cwd != null) {
			Log.printLine('Reset Working Directory: $cwd');
			Sys.setCwd(currentCwd);
		}
	}
	
	public function runGroup(groupName:String, configuration:Configuration, localConfiguration:Null<LocalConfiguration>):Void {
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
			this.run(task.name, configuration, localConfiguration);
		}
	}
	
	public function setConfigurationPaths(options:OptionSet):Void {
		if (options.hasShortOption('d') || options.hasLongOption('config-dir')) {
			var path = '';
			
			if (options.hasShortOption('d') && options.getShortValues('d').length > 0) {
				path = options.getShortValues('d')[0];
			} else if (options.hasLongOption('config-dir') && options.getLongValues('config-dir').length > 0) {
				path = options.getLongValues('config-dir')[0];
			}
			
			if (path != '') {
				//Path.addTrailingSlash will add a slash to a blank string
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
				
				if (path != '') {
					//Path.addTrailingSlash will add a slash to a blank string
					path = haxe.io.Path.addTrailingSlash(path);
					this.configurationFilePath = path + configurationFilePath;
				}
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
					throw new FileDoesNotExistsError(this.localConfigurationFilePath);
				}
			}
		}
		
		if (!FileSystem.exists(this.configurationFilePath)) {
			throw new FileDoesNotExistsError(this.configurationFilePath);
		}
	}
	
	public function showRequirements(configuration:Configuration, localConfiguration:Null<LocalConfiguration>):Void {
		if(configuration.countRequirements() > 0) {
			Log.printLine("Required Programs:");
			Log.printLine("----------------");
			for (requirement in configuration.requirements()) {
				Log.printLine(requirement.name);
				var line = requirement.name;
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
	
	public function testRequirements(configuration:Configuration, localConfiguration:Null<LocalConfiguration>):Void {
		if(configuration.countRequirements() > 0) {
				Log.printLine("Available Tasks:");
				Log.printLine("----------------");
			}
	}
}
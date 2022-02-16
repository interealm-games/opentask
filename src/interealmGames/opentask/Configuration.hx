package interealmGames.opentask;

import interealmGames.opentask.errors.NoRequirementLookupError;
import interealmGames.opentask.errors.NoRequirementLookupError;
import Map in Dictionary;

import interealmGames.common.dictionary.DictionaryTools;

import interealmGames.opentask.ConfigurationObject;
import interealmGames.opentask.Platform;
import interealmGames.opentask.Requirement;
import interealmGames.opentask.Task;

/**
 * Represents the user's task configuration, including task descriptions and required programs
 */
class Configuration
{
	static public function sortTasks(tasks:Iterator<Task>):Array<Task> {
		var ts:Array<Task> = [];
		for(task in tasks) {
			ts.push(task);
		}
		ts.sort(function(a:Task, b:Task):Int {
			var sa = a.name;
			var sb = b.name;
			if (sa > sb) {
				return 1;
			} else if (sa < sb) {
				return -1;
			}
			return 0;
		});
		return ts;
	}

	/** Version of this schema, semantic versioning */
	public var version:String;

	private var lookupCommand:Null<String> = null;

	private var platforms:Dictionary<Platform, PlatformConfigurationObject> = new Dictionary();
	
	/** The required programs needed to run the tasks */
	private var _requirements:Dictionary<String, Requirement> = new Dictionary();
	
	/** The tasks that can be run */
	private var _tasks:Dictionary<String, Task> = new Dictionary();
		
	public function new(configurationObject:ConfigurationObject) 
	{
		ConfigurationObjectValidator.validate(configurationObject);
		this.version = configurationObject.version;
		
		if (Reflect.hasField(configurationObject, 'requirements')) {
			for (requirementObject in configurationObject.requirements) {
				this.addRequirement(new Requirement(requirementObject));
			}
		}
		
		if (Reflect.hasField(configurationObject, 'tasks')) {
			for (taskObject in configurationObject.tasks) {
				this.addTask(new Task(taskObject));
			}
		}

		if (Reflect.hasField(configurationObject, 'lookupCommand')) {
			this.lookupCommand = configurationObject.lookupCommand;
		}

		for (platform in Type.allEnums(Platform)) {
			var platformName = platform.getName();
			if (Reflect.hasField(configurationObject, platformName)) {
				this.platforms.set(platform, Reflect.getProperty(configurationObject, platformName));
			}
		}
	}
	
	/**
	 * Adds a Requirement to this Configruation
	 * @param	requirement The Requirement to add
	 */
	public function addRequirement(requirement:Requirement) {
		if (!this._requirements.exists(requirement.command)) {
			this._requirements.set(requirement.command, requirement);
		}
	}
	
	/**
	 * Adds a task to this Configuration
	 * @param	task The Task to add
	 */
	public function addTask(task:Task):Void {
		if (!this._tasks.exists(task.name)) {
			this._tasks.set(task.name, task);
		}
	}
	
	/**
	 * Gives the number of Requirments in this Configuration
	 * @return The amount of Requirements
	 */
	public function countRequirements():Int {
		return DictionaryTools.size(this._requirements);
	}
	
	/**
	 * Gives the number of Tasks in this Configuration
	 * @return The amount of Tasks
	 */
	public function countTasks():Int {
		return DictionaryTools.size(this._tasks);
	}
	
	/**
	 * Gets a Requirement by its command
	 * @param	command The command of the Requirement
	 * @return The Requirement if exists, otherwise null
	 */
	public function getRequirement(command:String):Null<Requirement> {
		return this._requirements.get(command);
	}
	
	/**
	 * Gets a Task by its name
	 * @param	taskName The name of the Task
	 * @return The Task if exists, otherwise null
	 */
	public function getTask(taskName:String):Null<Task> {
		return this._tasks.get(taskName);
	}
	
	/**
	 * Whether a Requirement exists given the command
	 * @param	command The command of the Requirement
	 * @return Boolean
	 */
	public function hasRequirement(command:String):Bool {
		return this._requirements.exists(command);
	}
	
	/**
	 * Whether a Task exists given the name
	 * @param	taskName The name of the Task
	 * @return Boolean
	 */
	public function hasTask(taskName:String):Bool {
		return this._tasks.exists(taskName);
	}
	
	/**
	 * Gets all groups and places them in a Map/Dictionary
	 * whose keys is the Group name and whose values are Arrays 
	 * of the Group's Tasks, ordered by their Rank. No guarantees
	 * are made about the ordering of non-ranked Tasks.
	 * @return The Dictionary
	 */
	public function groups():Dictionary<String, Array<Task>> {
		var groups:Dictionary<String, Array<Task>> = new Dictionary();
		
		for (task in this._tasks.iterator()) {
			for (group in task.groups) {
				if (!groups.exists(group.name)) {
					groups.set(group.name, []);
				}
				
				groups.get(group.name).push(task);
			}
		}
		
		for (groupName in groups.keys()) {
			groups.get(groupName).sort(function(a:Task, b:Task):Int {
				var groupA = a.groups.get(groupName);
				var groupB = b.groups.get(groupName);
				
				return groupA.rank - groupB.rank;
			});
		}
		
		return groups;
	}

	public function groupNames():Array<String> {
		var groups:Dictionary<String, Int> = new Dictionary();
		var groupNames = [];
		
		for (task in this._tasks.iterator()) {
			for (group in task.groups) {
				if (!groups.exists(group.name)) {
					groups.set(group.name, 0);
					groupNames.push(group.name);
				}
			}
		}

		groupNames.sort(function(a, b) {
			if (a > b) { return 1; }
			if (a < b) { return -1; }
			return 0;
		});

		return groupNames;
	}
	
	/**
	 * Gets an Iterator for this Configuration's Requirements
	 * @return
	 */
	public function requirements():Iterator<Requirement> {
		return this._requirements.iterator();
	}
	
	
	/**
	 * Finds the correct command, given localized requirements (System, LocalConfiguration).
	 * @param	command The base command found in the Task
	 * @param	localConfiguration [OPTIONAL] The application's local configurations, if it exists
	 * @return The command of the program
	 */
	public function resolveCommand(platform:Platform, command:String, ?localConfiguration:Null<LocalConfiguration>):String {
		var _command = command;
		
		if (localConfiguration != null) {
			if (localConfiguration.hasCommand(command)) {
				_command = localConfiguration.getCommand(command);
			}
		} else {
			var requirement = this.getRequirement(command);
			if (requirement == null) {
				// Should this be an error?
				Log.warning('No requirement found for this command');
			} else {
				if (requirement.platforms.exists(platform)) {
					_command = requirement.resolveCommand(platform);
				}
			}
		}
		
		return _command;
	}

	public function resolveRequirementTest(platform:Platform, command:String, ?localConfiguration:Null<LocalConfiguration>) {
		var requirement = this.getRequirement(command);
		var command = this.resolveCommand(platform, requirement.command, localConfiguration);
		var testArgument = requirement.resolveTestArgument(platform);

		if (testArgument == null) {
			if(this.platforms.exists(platform)) {
				if (Reflect.hasField(this.platforms.get(platform), 'lookupCommand')) {
					return [this.platforms.get(platform).lookupCommand, command];
				}
			}

			if (this.lookupCommand != null) {
				return [this.lookupCommand, command];
			}
		} else {
			return [command, testArgument];
		}

		throw new NoRequirementLookupError(requirement.name);
	}
	
	/**
	 * Gets an Iterator for this Configuration's Tasks
	 * @return
	 */
	public function tasks():Array<Task> {
		return Configuration.sortTasks(this._tasks.iterator());
	}
}

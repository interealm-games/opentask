package interealmGames.opentask;

import Map in Dictionary;

import interealmGames.common.dictionary.DictionaryTools;

import interealmGames.opentask.ConfigurationObject;
import interealmGames.opentask.Requirement;
import interealmGames.opentask.Task;

/**
 * Represents the user's task configuration, including task descriptions and required programs
 */
class Configuration
{
	/** Version of this schema, semantic versioning */
	public var version:String;
	
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
	}
	
	/**
	 * Adds a Requirement to this Configruation
	 * @param	requirement The Requirement to add
	 */
	public function addRequirement(requirement:Requirement) {
		if (!this._requirements.exists(requirement.command)) {
			this._requirements.set(requirement.name, requirement);
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
		
		for (task in this.tasks()) {
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
	public function resolveCommand(command:String, localConfiguration:Null<LocalConfiguration>):String {
		var _command = command;
		var platform = PlatformTools.resolvePlatform();
		
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
	
	/**
	 * Gets an Iterator for this Configuration's Tasks
	 * @return
	 */
	public function tasks():Iterator<Task> {
		return this._tasks.iterator();
	}
}

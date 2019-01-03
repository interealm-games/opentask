package interealmGames.opentask;
import interealmGames.opentask.ConfigurationObject;
import interealmGames.opentask.Requirement;
import interealmGames.opentask.Task;

import Map in Dictionary;
import interealmGames.common.dictionary.DictionaryTools;

/**
 * ...
 * @author dmcblue
 */
class Configuration
{
	/** Version of this schema, semantic versioning */
	public var version:String;
	
	/** The required programs needed to run the tasks */
	public var _requirements:Dictionary<String, Requirement> = new Dictionary();
	
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
	
	public function addTask(task:Task) {
		if (!this._tasks.exists(task.name)) {
			this._tasks.set(task.name, task);
		}
	}
	
	public function addRequirement(requirement:Requirement) {
		if (!this._requirements.exists(requirement.command)) {
			this._requirements.set(requirement.command, requirement);
		}
	}
	
	public function countRequirements():Int {
		return DictionaryTools.size(this._requirements);
	}
	
	public function countTasks():Int {
		return DictionaryTools.size(this._tasks);
	}
	
	public function getRequirement(command:String):Null<Requirement> {
		return this._requirements.get(command);
	}
	
	public function getTask(taskName:String):Null<Task> {
		return this._tasks.get(taskName);
	}
	
	public function hasRequirement(command:String) {
		return this._requirements.exists(command);
	}
	
	public function hasTask(taskName:String) {
		return this._tasks.exists(taskName);
	}
	
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
		
		//Sorts this Array according to the comparison function f, where f(x,y) returns 0 if x == y, a positive Int if x > y and a negative Int if x < y.
		for (groupName in groups.keys()) {
			groups.get(groupName).sort(function(a:Task, b:Task):Int {
				var groupA = a.groups.get(groupName);
				var groupB = b.groups.get(groupName);
				
				return groupA.rank - groupB.rank;
			});
		}
		
		return groups;
	}
	
	public function requirements():Iterator<Requirement> {
		return this._requirements.iterator();
	}
	
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
				//should this be an error?
				// For now, just a warning
				//trace('No found requirement for this command');
				Log.warning('No requirement found for this command');
			} else {
				if (requirement.platforms.exists(platform)) {
					_command = requirement.platforms.get(platform);
				}
			}
		}
		
		return _command;
	}
	
	public function tasks():Iterator<Task> {
		return this._tasks.iterator();
	}
}

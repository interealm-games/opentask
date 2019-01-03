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
	public var requirements:Dictionary<String, Requirement> = new Dictionary();
	
	/** The tasks that can be run */
	private var _tasks:Dictionary<String, Task> = new Dictionary();
		
	public function new(configurationObject:ConfigurationObject) 
	{
		ConfigurationObjectValidator.validate(configurationObject);
		this.version = configurationObject.version;
		
		if (Reflect.hasField(configurationObject, 'requirements')) {
			for (requirementObject in configurationObject.requirements) {
				var requirement = new Requirement(requirementObject);
				if (!this.requirements.exists(requirement.command)) {
					this.requirements.set(requirement.command, requirement);
				}
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
	
	public function countTasks():Int {
		return DictionaryTools.size(this._tasks);
	}
	
	public function getRequirement(command:String):Null<Requirement> {
		return this.requirements.get(command);
	}
	
	public function getTask(taskName:String):Null<Task> {
		return this._tasks.get(taskName);
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
	
	public function tasks():Iterator<Task> {
		return this._tasks.iterator();
	}
}

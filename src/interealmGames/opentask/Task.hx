package interealmGames.opentask;
import interealmGames.common.dictionary.DictionaryTools;
import interealmGames.opentask.TaskObject;

import Map in Dictionary;

import interealmGames.opentask.Log;
import interealmGames.opentask.TaskObjectValidator;
import interealmGames.opentask.PlatformSpecificsObject;
import interealmGames.opentask.PlatformObject;
/**
 * ...
 * @author dmcblue
 */
class Task 
{
	/** Name to use at command line with the opentask executable */
	public var name:String;
	
	/** The executable command */
	public var command:String;
	
	/** Describes the task to human user */
	public var description:String = "";
	
	/** The group this task belongs to */
	public var groups:Dictionary<String, GroupObject> = new Dictionary();
	
	/** List of the arguments */
	public var arguments:Array<String> = [];
	
	/** Current Working Directory for the command */
	public var cwd:String = "";
	
	/** Adjusts the task options by platform */
	//var platformSpecifics:PlatformObject<PlatformSpecificsObject>
	public var platformSpecifics:Dictionary<Platforms, PlatformSpecificsObject> = new Dictionary();
	
	public function new(taskObject:TaskObject) 
	{
		TaskObjectValidator.validate(taskObject);
		this.name = taskObject.name;
		
		this.command = taskObject.command;
		
		if (Reflect.hasField(taskObject, 'description')) {
			this.description = taskObject.description;
		}
		
		if (Reflect.hasField(taskObject, 'groups')) {
			for (group in taskObject.groups) {
				this.groups.set(group.name, group);
			}
		}
		
		if (Reflect.hasField(taskObject, 'arguments')) {
			this.arguments = taskObject.arguments;
		}
		
		if (Reflect.hasField(taskObject, 'cwd')) {
			this.cwd = taskObject.cwd;
		}
		
		if (Reflect.hasField(taskObject, 'platformSpecifics')) {
			for (platformName in Reflect.fields(taskObject.platformSpecifics)) {
				var platform:Platforms = Type.createEnum(Platforms, platformName);
				this.platformSpecifics.set(platform, Reflect.field(taskObject.platformSpecifics, platformName));
			}
		}
	}
	
	public function formCommand(configuration:Configuration) {
		
	}
	
	public function resolveArguments():Array<String> {
		var arguments = this.arguments;
		var platform = PlatformTools.resolvePlatform();
		
		if (this.platformSpecifics.exists(platform)) {
			var pArguments = this.platformSpecifics.get(platform).arguments;
			if (pArguments != null) {
				arguments = pArguments;
			}
		}
		
		return arguments;
	}
	
	/**
	 * Use Configuration#resolveCommand instead
	 * @param	configuration
	 * @param	localConfiguration
	 * @return
	 */
	public function resolveCommand(configuration:Configuration, localConfiguration:Null<LocalConfiguration>):String {
		var command = this.command;
		var platform = PlatformTools.resolvePlatform();
		
		if (localConfiguration != null) {
			if (localConfiguration.hasCommand(this.command)) {
				command = localConfiguration.getCommand(this.command);
			}
		} else {
			var requirement = configuration.getRequirement(this.command);
			if (requirement == null) {
				//should this be an error?
				// For now, just a warning
				//trace('No found requirement for this command');
				Log.warning('No requirement found for this command');
			} else {
				if (requirement.platforms.exists(platform)) {
					command = requirement.resolveCommand(platform);
				}
			}
		}
		
		return command;
	}
	
	public function resolveCwd():Null<String> {
		var cwd = this.cwd;
		var platform = PlatformTools.resolvePlatform();
		
		if (this.platformSpecifics.exists(platform)) {
			var pCwd = this.platformSpecifics.get(platform).cwd;
			if (pCwd != null) {
				cwd = pCwd;
			}
		}
		
		return cwd.length > 0 ? cwd : null;
	}
}
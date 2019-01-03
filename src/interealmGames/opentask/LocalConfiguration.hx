package interealmGames.opentask;

import Map in Dictionary;
import interealmGames.opentask.LocalConfigurationValidator;
/**
 * Adjusts the master configuration for a local user
 */
class LocalConfiguration 
{
	/** Version of this schema */
	public var version:String;
	/** Object: Name of programs from Configurations requirements as key, path to program as value */
	public var commands:Dictionary<String,String> = new Dictionary();
	
	public function new(localConfigurationObject:LocalConfigurationObject) 
	{
		LocalConfigurationValidator.validate(localConfigurationObject);
		
		this.version = localConfigurationObject.version;
		
		if (Reflect.hasField(localConfigurationObject, 'commands')) {
			for (programName in Reflect.fields(localConfigurationObject.commands)) {
				this.commands.set(programName, Reflect.field(localConfigurationObject.commands, programName));
			}
		}
	}
	
	public function getCommand(commandName:String):String {
		return this.commands.get(commandName);
	}
	
	public function hasCommand(commandName:String):Bool {
		return this.commands.exists(commandName);
	}
}
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
	
	/**
	 * Gets a Command path by the Program name
	 * @param	programName
	 * @return
	 */
	public function getCommand(programName:String):String {
		return this.commands.get(programName);
	}
	
	/**
	 * Checks if a Command exists for a Program
	 * @param	programName
	 * @return
	 */
	public function hasCommand(programName:String):Bool {
		return this.commands.exists(programName);
	}
}
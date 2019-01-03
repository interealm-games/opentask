package interealmGames.opentask;

import Map in Dictionary;
import interealmGames.opentask.Platforms;
import interealmGames.opentask.RequirementObject;
/**
 * ...
 * @author dmcblue
 */
class Requirement 
{
	/** Name of the program */
	public var name:String;
	
	/** Default name/path of the executable as would be called from the terminal */
	public var command:String = "";
	
	/** A path or url to where one can find the executable to install it. */
	public var source:String = "";
	
	/** Semantic version of the program to be used */
	public var version:String = "";
	
	public var platforms:Dictionary<Platforms, String> = new Dictionary();
	
	public function new(requirementObject:RequirementObject) 
	{
		RequirementObjectValidator.validate(requirementObject);
		this.name = requirementObject.name;
		if (Reflect.hasField(requirementObject, 'command')) {
			this.command = requirementObject.command;
		}
		
		for (platform in Type.allEnums(Platforms)) {
			var platformName = platform.getName();
			if (Reflect.hasField(requirementObject, platformName)) {
				this.platforms.set(platform, Reflect.getProperty(requirementObject, platformName));
			}
		}
	}
	
}
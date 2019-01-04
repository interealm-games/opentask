package interealmGames.opentask;

import Map in Dictionary;
import interealmGames.opentask.Platforms;
import interealmGames.opentask.PlatformSpecificRequirement;
import interealmGames.opentask.RequirementObject;
/**
 * ...
 * @author dmcblue
 */
class Requirement 
{
	static public var DEFAULT_TEST_ARGUMENT = "--version"; // ? --help
	
	/** Name of the program */
	public var name:String;
	
	/** Default name/path of the executable as would be called from the terminal */
	public var command:String = "";
	
	/** A path or url to where one can find the executable to install it. */
	public var source:String = "";
	
	public var testArgument:String = "";
	
	/** Semantic version of the program to be used */
	public var version:String = "";
	
	public var platforms:Dictionary<Platforms, PlatformSpecificRequirement> = new Dictionary();
	
	public function new(requirementObject:RequirementObject) 
	{
		RequirementObjectValidator.validate(requirementObject);
		this.name = requirementObject.name;
		
		if (Reflect.hasField(requirementObject, 'command')) {
			this.command = requirementObject.command;
		}
		
		if (Reflect.hasField(requirementObject, 'source')) {
			this.source = requirementObject.source;
		}
		
		if (Reflect.hasField(requirementObject, 'testArgument')) {
			this.testArgument = requirementObject.testArgument;
		}
		
		if (Reflect.hasField(requirementObject, 'version')) {
			this.version = requirementObject.version;
		}
		
		for (platform in Type.allEnums(Platforms)) {
			var platformName = platform.getName();
			if (Reflect.hasField(requirementObject, platformName)) {
				this.platforms.set(platform, Reflect.getProperty(requirementObject, platformName));
			}
		}
	}
	
	public function resolveCommand(?platform:Platforms):String {
		if(platform == null) {
			platform = PlatformTools.resolvePlatform();
		}
		
		var command = this.command;
		
		if (this.platforms.exists(platform)) {
			var platformRequirement = this.platforms.get(platform);
			
			if (Reflect.hasField(platformRequirement, 'command')) {
				command = platformRequirement.command;
			}
		}
		
		return command;
	}
	
	public function resolveTestArgument(?platform:Platforms):String {
		if(platform == null) {
			platform = PlatformTools.resolvePlatform();
		}
		
		var testArgument = this.testArgument.length > 0 ? this.testArgument: Requirement.DEFAULT_TEST_ARGUMENT;
		
		if (this.platforms.exists(platform)) {
			var platformRequirement = this.platforms.get(platform);
			
			if (Reflect.hasField(platformRequirement, 'testArgument')) {
				testArgument = platformRequirement.testArgument;
			}
		}
		
		return testArgument;
	}
}
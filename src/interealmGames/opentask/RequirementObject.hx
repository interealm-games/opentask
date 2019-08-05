package interealmGames.opentask;

/**
  * Describes a program
  */
typedef RequirementObject = {
	/** Name of the program */
	name:String,
	
	/** Default name/path of the executable as would be called from the terminal */
	?command:String,
	
	/** A path or url to where one can find the executable to install it. */
	?source:String,
	
	/** Argument used to test the installation of the program which will have exit code 0. Default is '--version'. */
	?testArgument:String, 
	
	/** Semantic version of the program to be used */
	?version:String,
	
	/** Replacement for 'command' on specific platforms */
	?windows:PlatformSpecificRequirement,
	
	/**  */
	?macos:PlatformSpecificRequirement,
	
	/**  */
	?linux:PlatformSpecificRequirement,
	
	/**  */
	?bsd:PlatformSpecificRequirement
}

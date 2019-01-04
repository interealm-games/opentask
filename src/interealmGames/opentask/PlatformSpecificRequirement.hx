package interealmGames.opentask;

/**
 * Represents platform-specifics Requirment values
 */
typedef PlatformSpecificRequirement =
{
	/** Platform specific command for the program */
	?command:String,
	
	/** Platform specific argument that will return exit code 0 if the program is properly installed */
	?testArgument:String
}
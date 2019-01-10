package interealmGames.opentask.errors;

/**
 * Indicates that an application command was not given by the user
 */
class MissingCommandError extends BaseError 
{
	static public var TYPE = "MISSING_COMMAND";
	
	public function new() 
	{
		super(MissingCommandError.TYPE, "No command was provided.");
	}
}
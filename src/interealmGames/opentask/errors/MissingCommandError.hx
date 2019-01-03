package interealmGames.opentask.errors;

/**
 * ...
 */
class MissingCommandError extends BaseError 
{
	static public var TYPE = "MISSING_COMMAND";
	
	public function new() 
	{
		super(MissingCommandError.TYPE, "No command was provided.");
	}
}
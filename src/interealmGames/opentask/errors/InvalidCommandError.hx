package interealmGames.opentask.errors;

/**
 * 
 */
class InvalidCommandError extends BaseError 
{
	static public var TYPE = "INVALID_COMMAND";
	
	public function new(command:String) 
	{
		super(InvalidCommandError.TYPE, 'Unknown Command "$command"');
	}
}
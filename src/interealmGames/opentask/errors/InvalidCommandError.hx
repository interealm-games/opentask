package interealmGames.opentask.errors;

/**
 * Indicates that an invalid or unknown command has been given by the user
 */
class InvalidCommandError extends BaseError 
{
	static public var TYPE = "INVALID_COMMAND";
	
	public function new(command:String) 
	{
		super(InvalidCommandError.TYPE, 'Unknown Command "$command"');
	}
}

package interealmGames.opentask.errors;

/**
 * Indicates that a required command line argument is missing.
 */
class MissingArgumentError extends BaseError
{
	static public var TYPE = "MISSING_ARGUMENT";

	public function new(argumentName:String)
	{
		super(MissingArgumentError.TYPE, 'No argument for "$argumentName" was given to run.');
	}
}

package interealmGames.opentask.errors;

/**
 * Represents an invalid configuration
 */
class InvalidConfigurationError extends BaseError
{
	static public var TYPE = "INVALID_CONFIGURATION";

	public function new(filename:String)
	{
		super(InvalidConfigurationError.TYPE, 'Invalid configuration in ' + filename);
	}
}

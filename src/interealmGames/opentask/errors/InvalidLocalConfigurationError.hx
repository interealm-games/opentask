package interealmGames.opentask.errors;

/**
 * Represents an invalid local configuration
 */
class InvalidLocalConfigurationError extends BaseError 
{
	static public var TYPE = "INVALID_LOCAL_CONFIGURATION";
	
	public function new(filename:String) 
	{
		super(InvalidLocalConfigurationError.TYPE, 'Invalid local configuration in ' + filename);
	}
}
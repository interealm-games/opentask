package interealmGames.opentask.errors;

/**
 * Indicates that a needed file does not exist
 */
class NoRequirementLookupError extends BaseError 
{
	static public var TYPE = "NO_REQUIREMENT_LOOKUP";
	
	public function new(name:String) 
	{
		super(NoRequirementLookupError.TYPE, name);
	}
}

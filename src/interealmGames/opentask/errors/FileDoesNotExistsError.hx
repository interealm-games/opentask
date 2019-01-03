package interealmGames.opentask.errors;

/**
 * ...
 */
class FileDoesNotExistsError extends BaseError 
{
	static public var TYPE = "FILE_DOES_NOT_EXIST";
	
	public function new(filename:String) 
	{
		super(JsonParsingError.TYPE, filename);
	}
}
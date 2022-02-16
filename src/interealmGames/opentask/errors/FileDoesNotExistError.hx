package interealmGames.opentask.errors;

/**
 * Indicates that a needed file does not exist
 */
class FileDoesNotExistError extends BaseError 
{
	static public var TYPE = "FILE_DOES_NOT_EXIST";
	
	public function new(filename:String) 
	{
		super(FileDoesNotExistError.TYPE, filename);
	}
}

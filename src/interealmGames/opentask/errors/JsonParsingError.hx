package interealmGames.opentask.errors;

/**
 * Error on Json Parsing issue
 */
class JsonParsingError extends BaseError 
{
	static public var TYPE = "JSON_PARSE_ERROR";
	
	public function new(filename:String, message:String) 
	{
		super(JsonParsingError.TYPE, message + ' in ' + filename);
	}
}

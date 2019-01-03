package interealmGames.opentask.errors;

/**
 * Base Class for Errors
 */
class BaseError 
{
	public var type:String;
	public var message:String;
	public var causes:Array<BaseError> = [];
	
	public function new(type:String, message:String) 
	{
		this.type = type;
		this.message = message;
	}
	
	public function causedBy(cause:BaseError) {
		this.causes.push(cause);
		this.causes.concat(cause.causes);
		cause.causes = [];
	}
	
	public function toString():String {
		var errorText = this.type + ': ' + this.message + "\n";
		
		for (error in this.causes) {
			errorText += error.type + ': ' + error.message + "\n";
		}
		
		return errorText;
	}
}
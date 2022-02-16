package interealmGames.opentask.errors;

/**
 * Base Class for Errors
 */
class BaseError
{
	/**
	 * String indicating the kind of Error.
	 * Unique to the Class/type, in all caps with underscores between words.
	 */
	public var type:String;

	/**
	 * Human readable message explaining what occured
	 */
	public var message:String;

	/**
	 * Errors that led to this error. For example, bad Json parsing may lead to a lack of proper configuration.
	 */
	private var causes:Array<BaseError> = [];

	public function new(type:String, message:String)
	{
		this.type = type;
		this.message = message;
	}

	/**
	 * Indicates that this error cascades from or is a result of another error
	 * @param	cause The causal error.
	 */
	public function causedBy(cause:BaseError):Void {
		this.causes.push(cause);
		this.causes.concat(cause.causes);
		cause.causes = [];
	}

	/**
	 * A standardized format to display the error.
	 * @return This error as a string.
	 */
	public function toString():String {
		var errorText = this.type + ': ' + this.message + "\n";

		for (error in this.causes) {
			errorText += error.type + ': ' + error.message + "\n";
		}

		return errorText;
	}
}

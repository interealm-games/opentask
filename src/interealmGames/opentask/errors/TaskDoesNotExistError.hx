package interealmGames.opentask.errors;

/**
 * ...
 */
class TaskDoesNotExistError extends BaseError 
{
	static public var TYPE = "TASK_DOES_NOT_EXIST";
	
	public function new(taskName:String) 
	{
		super(TaskDoesNotExistError.TYPE, 'No task "$taskName" exists in this configuration.');
	}
}
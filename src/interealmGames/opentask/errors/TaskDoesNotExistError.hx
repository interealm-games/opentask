package interealmGames.opentask.errors;

/**
 * Indicates that no task with the name 'taskName' exists in the loaded configuration
 */
class TaskDoesNotExistError extends BaseError 
{
	static public var TYPE = "TASK_DOES_NOT_EXIST";
	
	public function new(taskName:String) 
	{
		super(TaskDoesNotExistError.TYPE, 'No task "$taskName" exists in this configuration.');
	}
}
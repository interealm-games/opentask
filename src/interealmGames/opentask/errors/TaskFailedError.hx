package interealmGames.opentask.errors;

/**
 * Indicates that no task with the name 'taskName' exists in the loaded configuration
 */
class TaskFailedError extends BaseError
{
	static public var TYPE = "TASK_FAILED";

	public function new(taskName:String, exitCode:Int)
	{
		super(TaskFailedError.TYPE, 'Task "$taskName" failed with exit code "$exitCode".');
	}
}

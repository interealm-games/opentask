package interealmGames.opentask.errors;

/**
 * Indicates that no task group with name 'groupName' exists.
 */
class GroupDoesNotExistError extends BaseError 
{
	static public var TYPE = "GROUP_DOES_NOT_EXIST";
	
	public function new(groupName:String) 
	{
		super(TaskDoesNotExistError.TYPE, 'No group "$groupName" exists in this configuration.');
	}
}

package interealmGames.opentask;
import interealmGames.opentask.PlatformSpecificsObject;
import interealmGames.opentask.PlatformObject;
/**
 * Way to group tasks together
 */
typedef GroupObject = {
	/** Name of the group */
	name:String,
	
	/** Used to order the running of group tasks, ties broken by precedence in file */
	?rank:Int
}

/**
 * Represents a task
 */
typedef TaskObject =
{
	/** Adjusts the task options by platform */
	> PlatformObject<PlatformSpecificsObject>,

	/** Name to use at command line with the opentask executable */
	name:String,
	
	/** The executable command */
	command:String,
	
	/** Describes the task to human user */
	?description:String,
	
	/** The group this task belongs to */
	?groups:Array<GroupObject>,
	
	/** List of the arguments */
	?arguments:Array<String>,
	
	/** Current Working Directory for the command */
	?cwd:String
}

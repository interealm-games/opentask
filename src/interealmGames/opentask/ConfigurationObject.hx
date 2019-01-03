package interealmGames.opentask;

import interealmGames.opentask.RequirementObject;

/**
 * Configures tasks to be run
 */
typedef ConfigurationObject =
{
	/** Version of this schema, semantic versioning */
	version:String,
	
	/** The tasks that can be run */
	tasks:Array<TaskObject>,
	
	/** The required programs needed to run the tasks */
	?requirements:Array<RequirementObject>	
}

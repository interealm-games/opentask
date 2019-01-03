package interealmGames.opentask;

/**
 * Adjusts the master configuration for a local user
 */
typedef LocalConfigurationObject =
{
	/** Version of this schema */
	version:String,
	/** Object: Name of programs from Configurations requirements as key, path to program as value */
	commands:Dynamic
}

package interealmGames.opentask;

/**
 * Represents platform-specifics Task values
 */
typedef PlatformSpecificsObject =
{
	/** Replacement for normalize arguments */
	?arguments:Array<String>,
	/** Current Working Directory for the command */
	?cwd:String
}

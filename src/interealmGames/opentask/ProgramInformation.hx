package interealmGames.opentask;

using interealmGames.common.StringToolsExtension;

import interealmGames.opentask.Application;
/**
 * Displays the information of this program
 */
class ProgramInformation 
{
	static public var PROGRAM_INFORMATION = "OpenTask v%s for %s
For more information, go to: https://github.com/dmcblue/opentask/
";
	static public function display() 
	{
		var platform = Sys.systemName();
		var version = Application.VERSION;
		
		Sys.println(StringTools.format(ProgramInformation.PROGRAM_INFORMATION, [version, platform]));
	}
}

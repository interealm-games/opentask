package interealmGames.opentask;

import interealmGames.common.fileSystem.FileSystem;
import interealmGames.common.CommandLine;
import neko.Lib;

/**
 * ...
 * @author dmcblue
 */
class Main 
{
	
	static function main() 
	{
		var options = CommandLine.getOptions();
		trace(options);
		
		var arguments = CommandLine.getArguments();
		trace(arguments);
		
		var paths = FileSystem.recursiveLoop("C:/www/interealm-games/editor-frontend/browser/src/interealmGames/browser/components", "scss");
		for (path in paths) {
			trace(path);
		}
	}
	
}
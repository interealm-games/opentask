package interealmGames.opentask;

import Sys;
import interealmGames.opentask.Platform;

/**
 * 
 */
class PlatformTools 
{
	static public function resolvePlatform():Null<Platform> {
		//"Windows", "Linux", "BSD" and "Mac"
		return switch(Sys.systemName()) {
			case 'Windows': Platform.windows;
			case 'Linux': Platform.linux;
			case 'BSD': Platform.bsd;
			case 'Mac': Platform.macos;
			default: null;
		}
	}
}

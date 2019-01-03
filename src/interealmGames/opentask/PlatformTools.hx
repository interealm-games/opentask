package interealmGames.opentask;

import Sys;
import interealmGames.opentask.Platforms;

/**
 * 
 */
class PlatformTools 
{
	static public function resolvePlatform():Null<Platforms> {
		//"Windows", "Linux", "BSD" and "Mac"
		return switch(Sys.systemName()) {
			case 'Windows': Platforms.windows;
			case 'Linux': Platforms.linux;
			case 'BSD': Platforms.bsd;
			case 'Mac': Platforms.macos;
			default: null;
		}
	}
}
package interealmGames.opentask;

/**
 * ...
 * @author dmcblue
 */
class Log 
{
	static private var PREFIX = "OpenTask:";
	static private var WARNING = "WARNING";
	
	static public function print(line:String = "") {
		Sys.print(line);
	}
	
	static public function printEnd(line:String = "") {
		Sys.println('$line');
	}
	
	static public function printLine(line:String = "") {
		Sys.println(Log.PREFIX + ' $line');
	}
	
	static public function printStart(line:String = "") {
		Sys.print(Log.PREFIX + ' $line');
	}
	
	static public function warning(message:String) {
		Sys.println(Log.PREFIX + ' ' + Log.WARNING + 'WARNING $message');
	}
}
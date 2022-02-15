package interealmGames.opentask;

import utest.Runner;
import utest.ui.Report;
import interealmGames.opentask.ConfigurationTest;
import interealmGames.opentask.RequirementTest;
import interealmGames.opentask.TaskTest;

/**
 * All tests for this package
 */
class Test {
	public static function main() {
		var runner:Runner = new Runner();
		runner.addCase(new ConfigurationTest());
		runner.addCase(new RequirementTest());
		runner.addCase(new TaskTest());
		Report.create(runner);
		runner.run();
	}
}

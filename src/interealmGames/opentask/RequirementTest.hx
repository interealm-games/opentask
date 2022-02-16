package interealmGames.opentask;

import interealmGames.opentask.Platform;
import interealmGames.opentask.Requirement;
import utest.Assert;
import utest.Async;
import utest.Test;

class RequirementTest extends Test
{
	public function testResolveCommand() {
		var requirement = new Requirement({
			name: "notcopy",
			command: "cp",
			windows: {
				command: "copy"
			}
		});
		var command = requirement.resolveCommand(Platform.windows);
		Assert.equals("copy", command);
	}

	public function testResolveTestArg() {
		var requirement = new Requirement({
			name: "notcopy",
			command: "cp",
			testArgument: "-version",
			windows: {
				command: "copy",
				testArgument: "/?"
			}
		});
		var arg = requirement.resolveTestArgument(Platform.windows);
		Assert.equals("/?", arg);
	}
}

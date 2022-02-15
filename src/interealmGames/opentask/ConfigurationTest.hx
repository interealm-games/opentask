package interealmGames.opentask;

import interealmGames.opentask.Platform;
import interealmGames.opentask.Configuration;
import utest.Assert;
import utest.Async;
import utest.Test;

class ConfigurationTest extends Test 
{
	public function testResolveCommand() {
		var configuration = new Configuration({
			version: "0.3.0",
			requirements: [{
				name: "notcopy",
				command: "cp",
				windows: {
					command: "copy"
				}
			}],
			tasks: [{
				name: "task",
				command: "linuxcmd",
				arguments: ["linuxarg"],
				macos: {
					arguments: ["macosarg"]
				}
			}]
		});
		var command = configuration.resolveCommand(Platform.windows, "cp");
		Assert.equals("copy", command);
	}
}

package interealmGames.opentask;

import interealmGames.opentask.Platform;
import interealmGames.opentask.Task;
import utest.Assert;
import utest.Async;
import utest.Test;

class TaskTest extends Test 
{
	public function testPlatformArgs() {
		var task = new Task({
			name: "task",
			command: "linuxcmd",
			arguments: ["linuxarg"],
			macos: {
				arguments: ["macosarg"]
			}
		});
		var args = task.resolveArguments(Platform.macos);
		Assert.same(["macosarg"], args);
	}

	public function testPlatformCwd() {
		var task = new Task({
			name: "task",
			command: "linuxcmd",
			arguments: ["linuxarg"],
			cwd: "/etc/nginx",
			windows: {
				cwd: "C:\\\\nginx"
			}
		});
		var cwd = task.resolveCwd(Platform.windows);
		Assert.equals("C:\\\\nginx", cwd);
	}
}

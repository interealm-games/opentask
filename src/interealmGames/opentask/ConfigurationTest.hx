package interealmGames.opentask;

import interealmGames.opentask.Task;
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

	public function testSortTask() {
		var tasks = [
			new Task({
				name: "taskZ",
				command: "taskZ",
				arguments: ["taskZ"]
			}),
			new Task({
				name: "taskA",
				command: "taskA",
				arguments: ["taskA"]
			})
		];

		var sorted = Configuration.sortTasks(tasks.iterator());
		Assert.equals(2, sorted.length);
		Assert.equals("taskA", sorted[0].name);
		Assert.equals("taskZ", sorted[1].name);
	}

	public function testTasks() {
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
				name: "taskZ",
				command: "taskZ",
				arguments: ["taskZ"]
			}, {
				name: "taskA",
				command: "taskA",
				arguments: ["taskA"]
			}]
		});

		var sorted = configuration.tasks();
		Assert.equals(2, sorted.length);
		Assert.equals("taskA", sorted[0].name);
		Assert.equals("taskZ", sorted[1].name);
	}
}

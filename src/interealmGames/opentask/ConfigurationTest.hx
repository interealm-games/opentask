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

	public function testGroupNames() {
		var configuration = new Configuration({
			version: "0.3.0",
			tasks: [{
				name: "taskZ",
				command: "taskZ",
				arguments: ["taskZ"],
				groups: [{
					"name": "groupZ",
					"rank": 1
				}, {
					"name": "groupA",
					"rank": 1
				}]
			}, {
				name: "taskA",
				command: "taskA",
				arguments: ["taskA"],
				groups: [{
					"name": "groupB",
					"rank": 1
				}]
			}]
		});

		var sorted = configuration.groupNames();
		Assert.equals(3, sorted.length);
		Assert.equals("groupA", sorted[0]);
		Assert.equals("groupB", sorted[1]);
		Assert.equals("groupZ", sorted[2]);
	}

	public function testResolveRequirementTest() {
		var configuration = new Configuration({
			version: "0.3.0",
			lookupCommand: "which",
			requirements: [{
				name: "notcopy",
				command: "cp",
				windows: {
					command: "copy"
				}
			}],
			tasks: []
		});

		var commands = configuration.resolveRequirementTest(Platform.windows, "cp");
		Assert.same(["which", "copy"], commands);

		var commands = configuration.resolveRequirementTest(Platform.linux, "cp");
		Assert.same(["which", "cp"], commands);

		configuration = new Configuration({
			version: "0.3.0",
			lookupCommand: "which",
			windows: {
				lookupCommand: "where",
			},
			requirements: [{
				name: "notcopy",
				command: "cp",
				windows: {
					command: "copy"
				}
			}],
			tasks: []
		});

		commands = configuration.resolveRequirementTest(Platform.windows, "cp");
		Assert.same(["where", "copy"], commands);

		configuration = new Configuration({
			version: "0.3.0",
			requirements: [{
				name: "notcopy",
				command: "cp",
				windows: {
					command: "copy"
				}
			}],
			tasks: []
		});

		Assert.raises(function() {
			commands = configuration.resolveRequirementTest(Platform.windows, "cp");
		}, "NO_REQUIREMENT_LOOKUP: notcopy");
	}
}

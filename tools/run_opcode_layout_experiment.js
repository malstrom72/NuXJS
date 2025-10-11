#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const {spawnSync} = require("child_process");

const REPO_ROOT = path.resolve(__dirname, "..");
const TARGET_SOURCE = path.resolve(REPO_ROOT, "src/NuXJS.cpp");
const BUILD_COMMANDS = {
        full: {
                command: "timeout",
                args: ["180", "./build.sh"],
                label: "timeout 180 ./build.sh",
        },
        nujs: {
                command: "bash",
                args: [
                        path.resolve(REPO_ROOT, "tools/BuildCpp.sh"),
                        "release",
                        "native",
                        "./output/NuXJS",
                        "tools/NuXJSREPL.cpp",
                        "src/NuXJS.cpp",
                        "src/stdlibJS.cpp",
                ],
                label: "bash tools/BuildCpp.sh release native ./output/NuXJS ...",
        },
};
const BENCHMARK_COMMAND = {
	command: "node",
	script: path.resolve(REPO_ROOT, "tools/benchmark.node.js"),
};

function fail(message) {
	console.error(message);
	process.exit(1);
}

function ensureRepoRoot() {
	process.chdir(REPO_ROOT);
}

function ensureCleanWorktree() {
	const status = spawnSync("git", ["status", "--porcelain", "--untracked-files=no"], {
		cwd: REPO_ROOT,
		encoding: "utf8",
		maxBuffer: 1024 * 1024,
	});
	if (status.error) {
		fail(`Failed to run git status: ${status.error.message}`);
	}
	if (status.status !== 0) {
		fail(`git status returned ${status.status}: ${status.stderr}`);
	}
	const output = status.stdout ? status.stdout.trim() : "";
	if (output.length !== 0) {
		const dirtyEntries = output.split(/\r?\n/).filter(Boolean).map((line) => {
			return line.length > 3 ? line.substring(3).trim() : line.trim();
		});
		const details = dirtyEntries.length > 0 ? ` Dirty entries:\n  ${dirtyEntries.join("\n  ")}` : "";
		fail(`Working tree has modifications to tracked files. Commit or stash changes before running experiments.${details}`);
	}
}

function parseArgs(argv) {
        const candidates = [];
        let runsPerBenchmark = 1;
        let iterations = 1;
        let outputPath = null;
        let buildMode = "full";
        let allowDirty = false;
        let testsPattern = "-";

        for (let i = 0; i < argv.length; ++i) {
                const arg = argv[i];
		if (arg === "--candidate") {
			if (i + 1 >= argv.length) {
				fail("--candidate requires a value.");
			}
			candidates.push(parseCandidate(argv[++i]));
		} else if (arg.startsWith("--candidate=")) {
			candidates.push(parseCandidate(arg.substring("--candidate=".length)));
		} else if (arg === "--runs") {
			if (i + 1 >= argv.length) {
				fail("--runs requires a value.");
			}
			runsPerBenchmark = parsePositiveInt(argv[++i], "--runs");
		} else if (arg.startsWith("--runs=")) {
			runsPerBenchmark = parsePositiveInt(arg.substring("--runs=".length), "--runs");
		} else if (arg === "--iterations") {
			if (i + 1 >= argv.length) {
				fail("--iterations requires a value.");
			}
			iterations = parsePositiveInt(argv[++i], "--iterations");
		} else if (arg.startsWith("--iterations=")) {
			iterations = parsePositiveInt(arg.substring("--iterations=".length), "--iterations");
                } else if (arg === "--output") {
                        if (i + 1 >= argv.length) {
                                fail("--output requires a value.");
                        }
                        outputPath = path.resolve(argv[++i]);
                } else if (arg.startsWith("--output=")) {
                        outputPath = path.resolve(arg.substring("--output=".length));
                } else if (arg === "--build") {
                        if (i + 1 >= argv.length) {
                                fail("--build requires a value.");
                        }
                        buildMode = parseBuildMode(argv[++i]);
                } else if (arg.startsWith("--build=")) {
                        buildMode = parseBuildMode(arg.substring("--build=".length));
                } else if (arg === "--allow-dirty") {
                        allowDirty = true;
                } else if (arg === "--tests") {
                        if (i + 1 >= argv.length) {
                                fail("--tests requires a value.");
                        }
                        testsPattern = parseTestsPattern(argv[++i]);
                } else if (arg.startsWith("--tests=")) {
                        testsPattern = parseTestsPattern(arg.substring("--tests=".length));
                } else if (arg === "--help" || arg === "-h") {
                        usage();
                        process.exit(0);
                } else {
                        fail(`Unknown argument: ${arg}`);
                }
        }

        if (candidates.length === 0) {
                candidates.push({
			label: "baseline",
			rewrite: null,
		});
	}

        return {
                candidates,
                runsPerBenchmark,
                iterations,
                outputPath,
                buildMode,
                allowDirty,
                testsPattern,
        };
}

function parseBuildMode(value) {
        if (!value) {
                fail("--build requires a non-empty mode name.");
        }
        if (!Object.prototype.hasOwnProperty.call(BUILD_COMMANDS, value)) {
                const known = Object.keys(BUILD_COMMANDS).join(", ");
                fail(`Unknown build mode '${value}'. Known modes: ${known}`);
        }
        return value;
}

function parseTestsPattern(value) {
        if (!value || value.length === 0) {
                fail("--tests requires a non-empty pattern.");
        }
        return value;
}

function parseCandidate(value) {
	if (!value || value.length === 0) {
		fail("Candidate value cannot be empty.");
	}
	const colon = value.indexOf(":");
	if (colon === -1) {
		return {
			label: value,
			rewrite: null,
		};
	}
	const label = value.substring(0, colon);
	const rewrite = value.substring(colon + 1);
	if (!label) {
		fail("Candidate label cannot be empty.");
	}
	if (!rewrite) {
		fail("Candidate rewrite script path cannot be empty.");
	}
	const resolved = path.resolve(rewrite);
	if (!fs.existsSync(resolved)) {
		fail(`Rewrite script does not exist: ${resolved}`);
	}
	return {
		label,
		rewrite: resolved,
	};
}

function parsePositiveInt(value, flag) {
	const parsed = Number.parseInt(value, 10);
	if (!Number.isFinite(parsed) || parsed <= 0) {
		fail(`${flag} must be a positive integer.`);
	}
	return parsed;
}

function usage() {
        console.log("Usage: run_opcode_layout_experiment [--candidate label[:rewrite.js]]... [--runs N] [--iterations N] [--output file] [--build mode] [--tests pattern] [--allow-dirty]");
        console.log("");
        console.log("Each candidate is rebuilt (applying the rewrite script when provided) and the benchmark harness is executed");
        console.log("the requested number of iterations. Results are persisted as JSON when --output is supplied.");
        console.log("Known build modes: " + Object.keys(BUILD_COMMANDS).join(", "));
        console.log("--allow-dirty skips the clean worktree check (use with caution).");
        console.log("--tests overrides the benchmark glob pattern (defaults to '-')");
}

function runCommand(command, args, options) {
	const start = process.hrtime.bigint();
	const child = spawnSync(command, args, {
		cwd: REPO_ROOT,
		encoding: "utf8",
		maxBuffer: 1024 * 1024 * 64,
		...options,
	});
	const end = process.hrtime.bigint();
	const durationMs = Number(end - start) / 1e6;
	if (child.error) {
		return {
			status: child.status === null ? 1 : child.status,
			signal: child.signal || null,
			durationMs,
			stdout: child.stdout || "",
			stderr: child.stderr || "",
			error: child.error.message,
		};
	}
	return {
		status: child.status === null ? 0 : child.status,
		signal: child.signal || null,
		durationMs,
		stdout: child.stdout || "",
		stderr: child.stderr || "",
		error: null,
	};
}

function applyRewrite(scriptPath) {
	if (!scriptPath) {
		return {
			command: null,
			result: null,
		};
	}
	const result = runCommand("node", [scriptPath]);
	return {
		command: `node ${scriptPath}`,
		result,
	};
}

function runBuild(buildMode) {
        const command = BUILD_COMMANDS[buildMode];
        if (!command) {
                fail(`Unsupported build mode: ${buildMode}`);
        }
        return runCommand(command.command, command.args);
}

function runBenchmark(runsPerBenchmark, testsPattern) {
	if (!fs.existsSync(BENCHMARK_COMMAND.script)) {
		fail(`Benchmark harness not found: ${BENCHMARK_COMMAND.script}.`);
	}
	const args = [
		BENCHMARK_COMMAND.script,
		testsPattern,
		"--horizontal",
		"--runs",
		String(runsPerBenchmark),
	];
	return runCommand(BENCHMARK_COMMAND.command, args);
}

function describeBuildCommand(mode) {
        const command = BUILD_COMMANDS[mode];
        if (!command) {
                return `<unknown build mode ${mode}>`;
        }
        if (command.label) {
                return command.label;
        }
        return `${command.command} ${command.args.join(" ")}`;
}

function describeBenchmarkCommand(runsPerBenchmark, testsPattern) {
	return `${BENCHMARK_COMMAND.command} ${BENCHMARK_COMMAND.script} ${testsPattern} --horizontal --runs ${runsPerBenchmark}`;
}

function main() {
        ensureRepoRoot();
        const options = parseArgs(process.argv.slice(2));
        if (!options.allowDirty) {
                ensureCleanWorktree();
        } else {
                console.warn("Warning: running experiments with a dirty working tree.");
        }
        const originalSource = fs.readFileSync(TARGET_SOURCE, "utf8");
        const results = {
                generatedAt: new Date().toISOString(),
                runsPerBenchmark: options.runsPerBenchmark,
                iterations: options.iterations,
                buildMode: options.buildMode,
                buildCommand: describeBuildCommand(options.buildMode),
                allowDirty: options.allowDirty,
                testsPattern: options.testsPattern,
                repository: REPO_ROOT,
                candidates: [],
        };

        for (const candidate of options.candidates) {
		console.log(`\n=== Candidate: ${candidate.label} ===`);
		fs.writeFileSync(TARGET_SOURCE, originalSource);
		let rewriteResult = null;
		if (candidate.rewrite !== null) {
			rewriteResult = applyRewrite(candidate.rewrite);
			if (rewriteResult.result && rewriteResult.result.status !== 0) {
				console.error(`Rewrite script failed for ${candidate.label}.`);
				console.error(rewriteResult.result.stderr);
				cleanupSource(originalSource);
				fail(`Failed to apply rewrite ${candidate.rewrite}.`);
			}
			console.log(`Applied rewrite script: ${candidate.rewrite}`);
		} else {
			console.log("Using baseline opcode order.");
		}

                const buildResult = runBuild(options.buildMode);
                console.log(`Build exited with status ${buildResult.status} in ${buildResult.durationMs.toFixed(0)}ms.`);
                if (buildResult.status !== 0) {
                        console.error(buildResult.stdout);
                        console.error(buildResult.stderr);
                        cleanupSource(originalSource);
			fail("Build failed.");
		}

		const iterationResults = [];
                for (let iteration = 0; iteration < options.iterations; ++iteration) {
                        console.log(`Running benchmarks (iteration ${iteration + 1} / ${options.iterations})...`);
                        const benchResult = runBenchmark(options.runsPerBenchmark, options.testsPattern);
                        console.log(`Benchmark exited with status ${benchResult.status} in ${benchResult.durationMs.toFixed(0)}ms.`);
                        iterationResults.push({
                                iteration,
                                status: benchResult.status,
                                signal: benchResult.signal,
                                durationMs: benchResult.durationMs,
                                stdout: benchResult.stdout,
                                stderr: benchResult.stderr,
                                command: describeBenchmarkCommand(options.runsPerBenchmark, options.testsPattern),
                        });
			if (benchResult.status !== 0) {
				console.error(benchResult.stdout);
				console.error(benchResult.stderr);
				break;
			}
		}

		results.candidates.push({
			label: candidate.label,
			rewriteScript: candidate.rewrite,
                        build: {
                                status: buildResult.status,
                                signal: buildResult.signal,
                                durationMs: buildResult.durationMs,
                                stdout: buildResult.stdout,
                                stderr: buildResult.stderr,
                                command: describeBuildCommand(options.buildMode),
                        },
                        iterations: iterationResults,
                });
        }

	cleanupSource(originalSource);

	if (options.outputPath) {
		const dir = path.dirname(options.outputPath);
		fs.mkdirSync(dir, {recursive: true});
		fs.writeFileSync(options.outputPath, JSON.stringify(results, null, 2));
		console.log(`Wrote results to ${options.outputPath}`);
	} else {
		console.log(JSON.stringify(results, null, 2));
	}
}

function cleanupSource(originalSource) {
	fs.writeFileSync(TARGET_SOURCE, originalSource);
	spawnSync("git", ["checkout", "--", TARGET_SOURCE], {
		cwd: REPO_ROOT,
		stdio: "ignore",
	});
}

main();

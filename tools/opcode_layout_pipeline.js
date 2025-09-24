#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const {spawnSync} = require("child_process");

const REPO_ROOT = path.resolve(__dirname, "..");

function usage() {
	console.log("Usage: opcode_layout_pipeline [options]\n");
	console.log("Automates the opcode-layout workflow: profiling, analysis, layout search, and validation benchmarks.\n");
	console.log("Options:");
	console.log("  --label NAME                Identifier used in generated artifact filenames (default: timestamp)");
	console.log("  --output-dir PATH           Output directory for artifacts (default: docs/opcode_profiles)");
	console.log("  --profile-runs N            Harness runs per benchmark during profiling (default: 1)");
	console.log("  --profile-tests PATTERN     Benchmark glob used during profiling (default: '-')");
	console.log("  --analysis-top N            Number of opcodes/transitions highlighted in reports (default: 20)");
	console.log("  --no-anneal                 Skip simulated annealing refinement (only greedy clustering)");
	console.log("  --anneal-iterations N       Iterations for simulated annealing (default: 50000)");
	console.log("  --anneal-start VALUE        Starting temperature for annealing (default: 1.0)");
	console.log("  --anneal-end VALUE          Ending temperature for annealing (default: 0.001)");
	console.log("  --experiment-runs N         Harness runs per benchmark during validation (default: 4)");
	console.log("  --experiment-iterations N   Number of benchmark iterations during validation (default: 3)");
	console.log("  --experiment-tests PATTERN  Benchmark glob used during validation (default: same as profiling)");
	console.log("  --build MODE                Build mode passed to run_opcode_layout_experiment.js (default: full)");
	console.log("  --allow-dirty               Skip clean worktree enforcement (dangerous)");
	console.log("  --skip-build                Do not run 'timeout 180 ./build.sh' before profiling");
	console.log("  -h, --help                  Show this help message and exit");
}

function fail(message) {
	console.error(message);
	process.exit(1);
}

function parseArgs(argv) {
	const options = {
		label: null,
		outputDir: path.resolve(REPO_ROOT, "docs/opcode_profiles"),
		profileRuns: 1,
		profileTests: "-",
		analysisTop: 20,
		runAnneal: true,
		annealIterations: 50000,
		annealStart: 1.0,
		annealEnd: 0.001,
		experimentRuns: 4,
		experimentIterations: 3,
		experimentTests: null,
		buildMode: "full",
		allowDirty: false,
		skipBuild: false,
	};
	for (let i = 0; i < argv.length; ++i) {
		const arg = argv[i];
		if (arg === "--label") {
			options.label = requireValue(argv, ++i, "--label");
		} else if (arg.startsWith("--label=")) {
			options.label = arg.substring("--label=".length);
		} else if (arg === "--output-dir") {
			options.outputDir = path.resolve(requireValue(argv, ++i, "--output-dir"));
		} else if (arg.startsWith("--output-dir=")) {
			options.outputDir = path.resolve(arg.substring("--output-dir=".length));
		} else if (arg === "--profile-runs") {
			const value = requireValue(argv, ++i, "--profile-runs");
			options.profileRuns = parsePositiveInt(value, "--profile-runs");
		} else if (arg.startsWith("--profile-runs=")) {
			const value = arg.substring("--profile-runs=".length);
			options.profileRuns = parsePositiveInt(value, "--profile-runs");
		} else if (arg === "--profile-tests") {
			options.profileTests = requireValue(argv, ++i, "--profile-tests");
		} else if (arg.startsWith("--profile-tests=")) {
			options.profileTests = arg.substring("--profile-tests=".length);
		} else if (arg === "--analysis-top") {
			const value = requireValue(argv, ++i, "--analysis-top");
			options.analysisTop = parsePositiveInt(value, "--analysis-top");
		} else if (arg.startsWith("--analysis-top=")) {
			const value = arg.substring("--analysis-top=".length);
			options.analysisTop = parsePositiveInt(value, "--analysis-top");
		} else if (arg === "--no-anneal") {
			options.runAnneal = false;
		} else if (arg === "--anneal-iterations") {
			const value = requireValue(argv, ++i, "--anneal-iterations");
			options.annealIterations = parsePositiveInt(value, "--anneal-iterations");
		} else if (arg.startsWith("--anneal-iterations=")) {
			const value = arg.substring("--anneal-iterations=".length);
			options.annealIterations = parsePositiveInt(value, "--anneal-iterations");
		} else if (arg === "--anneal-start") {
			const value = requireValue(argv, ++i, "--anneal-start");
			options.annealStart = parsePositiveFloat(value, "--anneal-start");
		} else if (arg.startsWith("--anneal-start=")) {
			const value = arg.substring("--anneal-start=".length);
			options.annealStart = parsePositiveFloat(value, "--anneal-start");
		} else if (arg === "--anneal-end") {
			const value = requireValue(argv, ++i, "--anneal-end");
			options.annealEnd = parsePositiveFloat(value, "--anneal-end");
		} else if (arg.startsWith("--anneal-end=")) {
			const value = arg.substring("--anneal-end=".length);
			options.annealEnd = parsePositiveFloat(value, "--anneal-end");
		} else if (arg === "--experiment-runs") {
			const value = requireValue(argv, ++i, "--experiment-runs");
			options.experimentRuns = parsePositiveInt(value, "--experiment-runs");
		} else if (arg.startsWith("--experiment-runs=")) {
			const value = arg.substring("--experiment-runs=".length);
			options.experimentRuns = parsePositiveInt(value, "--experiment-runs");
		} else if (arg === "--experiment-iterations") {
			const value = requireValue(argv, ++i, "--experiment-iterations");
			options.experimentIterations = parsePositiveInt(value, "--experiment-iterations");
		} else if (arg.startsWith("--experiment-iterations=")) {
			const value = arg.substring("--experiment-iterations=".length);
			options.experimentIterations = parsePositiveInt(value, "--experiment-iterations");
		} else if (arg === "--experiment-tests") {
			options.experimentTests = requireValue(argv, ++i, "--experiment-tests");
		} else if (arg.startsWith("--experiment-tests=")) {
			options.experimentTests = arg.substring("--experiment-tests=".length);
		} else if (arg === "--build") {
			options.buildMode = requireValue(argv, ++i, "--build");
		} else if (arg.startsWith("--build=")) {
			options.buildMode = arg.substring("--build=".length);
		} else if (arg === "--allow-dirty") {
			options.allowDirty = true;
		} else if (arg === "--skip-build") {
			options.skipBuild = true;
		} else if (arg === "-h" || arg === "--help") {
			usage();
			process.exit(0);
		} else if (arg.startsWith("-")) {
			fail(`Unknown option: ${arg}`);
		} else {
			fail(`Unexpected argument: ${arg}`);
		}
	}
	if (!options.label || options.label.trim().length === 0) {
		options.label = buildDefaultLabel();
	}
	options.label = sanitizeLabel(options.label);
	if (!options.experimentTests) {
		options.experimentTests = options.profileTests;
	}
	return options;
}

function requireValue(argv, index, flag) {
	if (index >= argv.length) {
		fail(`${flag} requires a value.`);
	}
	return argv[index];
}

function parsePositiveInt(value, flag) {
	const parsed = Number.parseInt(value, 10);
	if (!Number.isFinite(parsed) || parsed <= 0) {
		fail(`${flag} must be a positive integer.`);
	}
	return parsed;
}

function parsePositiveFloat(value, flag) {
	const parsed = Number.parseFloat(value);
	if (!Number.isFinite(parsed) || parsed <= 0) {
		fail(`${flag} must be a positive number.`);
	}
	return parsed;
}

function buildDefaultLabel() {
	const now = new Date();
	const year = now.getFullYear();
	const month = String(now.getMonth() + 1).padStart(2, "0");
	const day = String(now.getDate()).padStart(2, "0");
	const hour = String(now.getHours()).padStart(2, "0");
	const minute = String(now.getMinutes()).padStart(2, "0");
	return `${year}-${month}-${day}-${hour}${minute}`;
}

function sanitizeLabel(label) {
	return label.replace(/[^A-Za-z0-9._-]/g, "-");
}

function ensureRepoRoot() {
	process.chdir(REPO_ROOT);
}

function ensureCleanWorktree() {
	const status = spawnSync("git", ["status", "--porcelain"], {
		cwd: REPO_ROOT,
		encoding: "utf8",
	});
	if (status.error) {
		fail(`Failed to run git status: ${status.error.message}`);
	}
	if (status.status !== 0) {
		fail(`git status returned ${status.status}: ${status.stderr}`);
	}
	if (status.stdout.trim().length !== 0) {
		fail("Working tree is dirty. Commit or stash changes before running the pipeline or pass --allow-dirty.");
	}
}

function runCommand(command, args, options = {}) {
	console.log(`\n$ ${command} ${args.join(" ")}`);
	const result = spawnSync(command, args, {
		cwd: REPO_ROOT,
		encoding: "utf8",
		maxBuffer: 1024 * 1024 * 128,
		...options,
	});
	if (result.stdout) {
		process.stdout.write(result.stdout);
	}
	if (result.stderr) {
		process.stderr.write(result.stderr);
	}
	if (result.error) {
		fail(`Failed to run ${command}: ${result.error.message}`);
	}
	return result;
}

function runBuild(options) {
	if (options.skipBuild) {
		console.log("Skipping initial build as requested.");
		return;
	}
	const result = runCommand("timeout", ["180", "./build.sh"]);
	if (result.status !== 0) {
		fail("Initial build failed. Aborting pipeline.");
	}
}

function profileOpcodes(options, paths) {
	const env = {
		...process.env,
		NUXJS_OPCODE_PROFILE_OUT: paths.profile,
	};
	const args = ["tools/benchmark.pika", options.profileTests, "--runs", String(options.profileRuns)];
	const result = runCommand(path.resolve(REPO_ROOT, "externals/PikaCmd/PikaCmd"), args, {env});
	if (result.status !== 0) {
		fail("Benchmark harness failed while gathering opcode profile.");
	}
	if (!fs.existsSync(paths.profile)) {
		fail(`Profiling output was not produced at ${paths.profile}`);
	}
}

function analyzeProfile(options, paths) {
	const args = [
		path.resolve(REPO_ROOT, "tools/analyze_opcode_profile.js"),
		paths.profile,
		`--report=${paths.analysisReport}`,
		`--dot=${paths.analysisGraph}`,
		`--order=${paths.greedyOrder}`,
		`--greedy-rewrite=${paths.greedyRewrite}`,
		`--top=${options.analysisTop}`,
	];
	if (options.runAnneal) {
		args.push("--anneal");
		args.push(`--anneal-order=${paths.annealOrder}`);
		args.push(`--anneal-iterations=${options.annealIterations}`);
		args.push(`--anneal-start=${options.annealStart}`);
		args.push(`--anneal-end=${options.annealEnd}`);
		args.push(`--anneal-rewrite=${paths.annealRewrite}`);
	}
	const result = runCommand("node", args);
	if (result.status !== 0) {
		fail("Opcode profile analysis failed.");
	}
	if (!fs.existsSync(paths.analysisReport)) {
		fail("Expected analysis report was not generated.");
	}
	if (!fs.existsSync(paths.greedyRewrite)) {
		fail("Greedy rewrite script was not generated.");
	}
	if (options.runAnneal && !fs.existsSync(paths.annealRewrite)) {
		console.warn("Warning: anneal rewrite script missing; annealed candidate will be skipped.");
	}
}

function runExperiments(options, paths) {
	const args = [
		path.resolve(REPO_ROOT, "tools/run_opcode_layout_experiment.js"),
		"--output", paths.experimentResults,
		"--build", options.buildMode,
		"--runs", String(options.experimentRuns),
		"--iterations", String(options.experimentIterations),
		"--tests", options.experimentTests,
		"--candidate", "baseline",
		"--candidate", `greedy:${paths.greedyRewrite}`,
	];
	if (options.runAnneal && fs.existsSync(paths.annealRewrite)) {
		args.push("--candidate", `anneal:${paths.annealRewrite}`);
	}
	if (options.allowDirty) {
		args.push("--allow-dirty");
	}
	const result = runCommand("node", args);
	if (result.status !== 0) {
		fail("Opcode layout experiment runner reported an error.");
	}
	if (!fs.existsSync(paths.experimentResults)) {
		fail("Experiment results JSON was not produced.");
	}
}

function summarizeExperiments(paths) {
	const args = [
		path.resolve(REPO_ROOT, "tools/analyze_opcode_layout_results.js"),
		"--output", paths.experimentSummary,
		paths.experimentResults,
	];
	const result = runCommand("node", args);
	if (result.status !== 0) {
		fail("Failed to analyze opcode layout experiments.");
	}
	if (!fs.existsSync(paths.experimentSummary)) {
		fail("Experiment summary report was not generated.");
	}
}

function buildPaths(options) {
	fs.mkdirSync(options.outputDir, {recursive: true});
	const prefix = options.label;
	return {
		profile: path.resolve(options.outputDir, `${prefix}-profile.json`),
		analysisReport: path.resolve(options.outputDir, `${prefix}-analysis.md`),
		analysisGraph: path.resolve(options.outputDir, `${prefix}-graph.dot`),
		greedyOrder: path.resolve(options.outputDir, `${prefix}-greedy-order.txt`),
		greedyRewrite: path.resolve(options.outputDir, `${prefix}-greedy-rewrite.js`),
		annealOrder: path.resolve(options.outputDir, `${prefix}-anneal-order.txt`),
		annealRewrite: path.resolve(options.outputDir, `${prefix}-anneal-rewrite.js`),
		experimentResults: path.resolve(options.outputDir, `${prefix}-experiments.json`),
		experimentSummary: path.resolve(options.outputDir, `${prefix}-summary.md`),
	};
}

function main() {
	ensureRepoRoot();
	const options = parseArgs(process.argv.slice(2));
	if (!options.allowDirty) {
		ensureCleanWorktree();
	} else {
		console.warn("Warning: running pipeline with a dirty working tree.");
	}
	const paths = buildPaths(options);
	console.log("Artifacts will be written to:");
	Object.entries(paths).forEach(([key, value]) => {
		console.log(`  ${key}: ${value}`);
	});
	runBuild(options);
	profileOpcodes(options, paths);
	analyzeProfile(options, paths);
	runExperiments(options, paths);
	summarizeExperiments(paths);
	console.log("\nOpcode layout pipeline completed successfully.");
	console.log(`Profile: ${paths.profile}`);
	console.log(`Analysis report: ${paths.analysisReport}`);
	console.log(`Experiment summary: ${paths.experimentSummary}`);
}

main();

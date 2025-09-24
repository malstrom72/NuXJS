#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");
const child_process = require("child_process");

const LF = "\n";
const PLATFORM = process.platform === "win32" ? "WINDOWS" : "UNIX";
let STANDARD_COLOR = "";
let SUCCESS_COLOR = "";
let FAILURE_COLOR = "";
let INPUT_COLOR = "";
let GOT_COLOR = "";
let EXPECTED_COLOR = "";
let RESET_COLOR = "";

if (PLATFORM === "UNIX") {
	STANDARD_COLOR = "\x1B[1;37m";
	SUCCESS_COLOR = "\x1B[0;32m";
	FAILURE_COLOR = "\x1B[1;31m";
	INPUT_COLOR = "\x1B[1;37m";
	GOT_COLOR = "\x1B[1;31m";
	EXPECTED_COLOR = "\x1B[1;32m";
	RESET_COLOR = "\x1B[0m";
}

const files = [];
const fails = [];
let exe = PLATFORM === "WINDOWS" ? "Debug\\NuXJS.exe -s" : "build/Debug/NuXJS -s";
let errorsToo = false;
let keepInputFiles = false;
let inputFileDir = "";
let didHelp = false;
let exitCode = 0;
let tempDir;

function help() {
	console.log("test [-e(rrors too)] [-k(eep input files) <in dir>] [-x <exe command>] <test files / dirs>");
	didHelp = true;
}

function repeat(str, count) {
	if (count <= 0) return "";
	return str.repeat(count);
}

function trimTrailingNewlines(text) {
	return text.replace(/\n+$/g, "");
}

function forEachLine(text, callback) {
	let remaining = text;
	while (remaining.length > 0) {
		const idx = remaining.indexOf(LF);
		if (idx === -1) {
			callback(remaining);
			break;
		}
		callback(remaining.slice(0, idx));
		remaining = remaining.slice(idx + 1);
	}
}

function toNativePath(p) {
	if (PLATFORM === "WINDOWS") return p.replace(/\//g, "\\");
	return p;
}

function quotePath(p) {
	const native = toNativePath(p);
	if (PLATFORM === "WINDOWS") {
			return '"' + native.replace(/"/g, '\\"') + '"';
	}
	return "'" + native.replace(/'/g, "'\\''") + "'";
}

function makeTempDir() {
	const prefix = path.join(os.tmpdir(), "PikaTemp-");
	return fs.mkdtempSync(prefix);
}

function wipeTempDir(dir) {
	try {
		fs.rmSync(dir, { recursive: true, force: true });
	} catch (err) {
		if (err && err.code !== "ENOENT") throw err;
	}
}

function runPipe(command, throwOnError = true) {
	const result = child_process.spawnSync(command, {
		shell: true,
		encoding: "utf8",
	});
	if (result.error) throw result.error;
	const stdout = (result.stdout || "").trim();
	const stderr = result.stderr || "";
	const status = typeof result.status === "number" ? result.status : 0;
	if (throwOnError && status !== 0) {
		let message = `Error executing ${command} (${status})`;
		if (stderr) {
			let sanitized = stderr.replace(/[\t\r\n]+/g, " ").trim();
			if (sanitized.length > 80) sanitized = sanitized.slice(0, 77) + "...";
			if (sanitized) message += `: ${sanitized} (${status})`;
		}
		throw new Error(message);
	}
	return { stdout, stderr, status };
}

function formatDisplayPath(actual, isDir) {
	let rel = path.relative(process.cwd(), actual);
	if (!rel) rel = ".";
	let display = rel.replace(/\\/g, "/");
	if (isDir && !display.endsWith("/")) display += "/";
	return display;
}

function combineDisplay(parentDisplay, childName, isDir) {
	let base = parentDisplay.endsWith("/") ? parentDisplay : parentDisplay + "/";
	let display = base + childName;
	if (isDir && !display.endsWith("/")) display += "/";
	return display;
}

function ensureDirExists(dir) {
	fs.mkdirSync(dir, { recursive: true });
}

function parseArgs(argv) {
	for (let i = 0; i < argv.length; ++i) {
		const arg = argv[i];
		if (arg.startsWith("-")) {
			const opt = arg.slice(1, 2);
			const nextArg = () => {
				if (i + 1 >= argv.length) {
					throw new Error("Missing argument for -" + opt);
				}
				return argv[++i];
			};
			if (opt === "?" || opt === "h") {
				help();
			} else if (opt === "e") {
				errorsToo = true;
			} else if (opt === "k") {
				keepInputFiles = true;
				inputFileDir = nextArg();
			} else if (opt === "x") {
				exe = nextArg();
			} else {
				throw new Error("Unknown command line option. Use -h for help.");
			}
		} else {
			files.push(arg);
		}
	}
	if (files.length === 0) help();
}

function readText(filePath) {
	return fs.readFileSync(filePath, "utf8");
}

function writeText(filePath, text) {
	ensureDirExists(path.dirname(filePath));
	fs.writeFileSync(filePath, text, "utf8");
}

function testFile(actualPath) {
	const testFilename = path.basename(actualPath);
	console.log(STANDARD_COLOR + testFilename);
	console.log(repeat("=", testFilename.length));

	let ioSource = readText(actualPath).replace(/\r\n/g, "\n");
	let sectionInput = "";
	let sectionOutput = "";
	const sections = [];
	let skipSection = false;

	const addSection = () => {
		if (!skipSection) sections.push({ input: sectionInput, output: sectionOutput });
		skipSection = false;
		sectionInput = "";
		sectionOutput = "";
	};

	let warnAboutExpectedErrors = false;

	forEachLine(ioSource, (line) => {
		const directive = line.slice(0, 1);
		const command = line.length >= 2 ? line.slice(2) : "";
		if (directive === ">") {
			if (sectionOutput !== "") addSection();
			sectionInput += command + LF;
		} else if (directive === "<") {
			sectionOutput += command + LF;
		} else if (directive === "!") {
			if (errorsToo) {
				sectionOutput += command + LF;
			} else {
				warnAboutExpectedErrors = true;
				skipSection = true;
			}
		} else if (directive === "-") {
			addSection();
		} else if (directive !== "/") {
			skipSection = true;
		}
	});

	if (sectionOutput !== "") addSection();

	if (warnAboutExpectedErrors) {
		console.log("Warning! Expects one or more tests to fail. Run with -e to test these too.");
	}

	let allInput = "";
	let allOutput = "";
	sections.forEach((section, index) => {
		const header = `----<<<< ${index} >>>>----`;
		section.header = header;
		allInput += `print("${header}");` + LF + LF + section.input + LF;
		allOutput += header + LF + section.output;
	});

	allOutput = trimTrailingNewlines(allOutput);

	let inputFile;
	if (keepInputFiles) {
		const resolvedDir = path.resolve(inputFileDir);
		const baseName = path.parse(testFilename).name;
		inputFile = path.join(resolvedDir, baseName + ".js");
	} else {
		inputFile = path.join(tempDir, "test");
	}

	writeText(inputFile, allInput);

	const command = exe + (errorsToo ? " <" : " ") + quotePath(inputFile);
	const { stdout, status } = runPipe(command, false);

	if (status === 2) throw new Error("user aborted");

	let result = stdout.replace(/\r\n/g, "\n");
	result = trimTrailingNewlines(result);

	if (result === allOutput) {
		console.log(SUCCESS_COLOR + "Success!");
		console.log("");
	} else {
		console.log(FAILURE_COLOR + "Failure!");
		console.log("");
		exitCode = 1;
		process.exitCode = 1;

		let sectionIndex = -1;
		let collected = "";

		const flush = () => {
			if (sectionIndex >= 0 && collected !== sections[sectionIndex].output) {
				console.log(INPUT_COLOR + "INPUT");
				console.log(repeat("-", 40));
				console.log(sections[sectionIndex].input);
				console.log(GOT_COLOR + "GOT");
				console.log(repeat("-", 40));
				console.log(collected);
				console.log(EXPECTED_COLOR + "EXPECTED");
				console.log(repeat("-", 40));
				console.log(sections[sectionIndex].output);
				console.log("");
			}
		};

		forEachLine(result, (line) => {
			if (sectionIndex + 1 < sections.length && line === sections[sectionIndex + 1].header) {
				flush();
				collected = "";
				++sectionIndex;
			} else {
				collected += line + LF;
			}
		});

		flush();

		fails.push(testFilename);
	}
}

function testDir(actualPath, displayPath) {
	const stats = fs.statSync(actualPath);
	const isDir = stats.isDirectory();
	const display = displayPath !== undefined ? displayPath : formatDisplayPath(actualPath, isDir);

	console.log(STANDARD_COLOR + display);
	console.log(repeat("#", display.length));
	console.log("");

	if (!isDir) {
			testFile(actualPath);
			return;
	}

	const entries = fs.readdirSync(actualPath, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name));
	for (const entry of entries) {
		const childActual = path.join(actualPath, entry.name);
		if (entry.isDirectory()) {
			const childDisplay = combineDisplay(display, entry.name, true);
			testDir(childActual, childDisplay);
		} else if (entry.isFile()) {
			testFile(childActual);
		}
	}
}

function processTarget(target) {
	const actual = path.resolve(target);
	if (!fs.existsSync(actual)) {
		throw new Error(`Path not found: ${target}`);
	}
	const stats = fs.statSync(actual);
	const display = formatDisplayPath(actual, stats.isDirectory());
	testDir(actual, display);
}

try {
	parseArgs(process.argv.slice(2));
	tempDir = makeTempDir();

	if (!didHelp) {
		for (const target of files) {
			processTarget(target);
		}
		if (fails.length > 0) {
			let summary = FAILURE_COLOR + "Fails: ";
			fails.forEach((name) => {
				summary += name + ", ";
			});
			summary = summary.slice(0, -2);
			console.log(summary);
		}
	}
} catch (err) {
	console.error(err && err.message ? err.message : String(err));
	exitCode = 1;
	process.exitCode = 1;
} finally {
	if (tempDir) wipeTempDir(tempDir);
	console.log(RESET_COLOR);
	if (exitCode !== 0 && (process.exitCode === undefined || process.exitCode === 0)) process.exitCode = exitCode;
}

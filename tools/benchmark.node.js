#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");
const child_process = require("child_process");

function main() {
        let tests;
        let exe;
        let ignoreGold = false;
        let runs = 5;
        let makeGold = false;
        let runsOverride = false;
        let flipOutput = false;
	const args = process.argv.slice(2);

	function assignRuns(value) {
		if (value === undefined || value === null || String(value).trim() === "") {
			throw new Error("Value for --runs must be a positive integer.");
		}
		const num = Number(value);
		if (!Number.isFinite(num) || num < 1 || Math.floor(num) !== num) {
			throw new Error("Value for --runs must be a positive integer.");
		}
		runs = num;
		runsOverride = true;
	}

        for (let i = 0; i < args.length; ++i) {
                const arg = args[i];
                if (arg === "ignoregold") {
                        ignoreGold = true;
                } else if (arg === "--flip") {
                        flipOutput = true;
                } else if (arg === "--runs" || arg === "-r") {
                        if (++i >= args.length) throw new Error("Missing value for --runs.");
                        assignRuns(args[i]);
		} else if (arg.startsWith("--runs=")) {
			assignRuns(arg.slice(7));
		} else if (arg.startsWith("-r=")) {
			assignRuns(arg.slice(3));
		} else if (arg === "makegold" && tests !== undefined && exe === undefined) {
			makeGold = true;
		} else if (tests === undefined) {
			tests = arg;
		} else if (exe === undefined) {
			exe = arg;
		} else if (!runsOverride && isNumericInteger(arg)) {
			assignRuns(arg);
		} else {
			throw new Error("Unknown command line argument: " + arg);
		}
	}

	if (tests === undefined || tests === "-") tests = "*.js";
	else if (!tests.endsWith(".js")) tests += ".js";

	if (makeGold) exe = undefined;

	if (!exe) exe = process.platform === "win32" ? ".\output\NuXJS -s -t" : "./output/NuXJS -s -t";

	const tempDir = makeTempDir();
	const outPath = path.join(tempDir, "out");
	const timePath = path.join(tempDir, "time");

        const names = collectBenchmarkNames(tests);
        const widths = Object.create(null);
        const timeLines = Object.create(null);
        const runColumns = Object.create(null);
        for (const name of names) {
                widths[name] = name.length;
                timeLines[name] = [];
                runColumns[name] = [];
        }

	const overallMedians = [];
	let deferredError = null;
	try {
                for (const name of names) {
                        const result = runBenchmark({
                                name,
                                exe,
                                runs,
                                ignoreGold,
                                makeGold,
                                outPath,
                                timePath,
                                widths,
                                timeLines,
                                runColumns,
                        });
                        if (result !== null) overallMedians.push(result);
                }
        } catch (error) {
                deferredError = error;
        }

        const summaryLines = flipOutput
                ? buildFlippedLines(names, runColumns, timeLines)
                : buildSummaryLines(names, widths, timeLines);
        for (const line of summaryLines) console.log(line);

	cleanupTempDir(tempDir);

        if (overallMedians.length !== 0) {
                overallMedians.sort((a, b) => a.value - b.value);
                const mid = Math.floor(overallMedians.length / 2);
                let overallDisplay;
                if (overallMedians.length % 2 !== 0) overallDisplay = overallMedians[mid].raw;
                else overallDisplay = formatNumber((overallMedians[mid - 1].value + overallMedians[mid].value) / 2);
                const total = overallMedians.reduce((sum, entry) => sum + entry.value, 0);
                const averageDisplay = formatNumber(total / overallMedians.length);
                console.log("\nmedian of all tests: " + overallDisplay + "s");
                console.log("average of all tests: " + averageDisplay + "s");
        }

	if (deferredError) {
		const message = deferredError && deferredError.message ? deferredError.message : String(deferredError);
		console.log(message);
		process.exitCode = 1;
	}
}

function isNumericInteger(value) {
	if (typeof value === "number") return Number.isInteger(value) && value >= 0;
	if (typeof value !== "string") return false;
	const trimmed = value.trim();
	if (trimmed.length === 0) return false;
	const num = Number(trimmed);
	return Number.isFinite(num) && Math.floor(num) === num;
}

function runBenchmark(options) {
        const { name, exe, runs, ignoreGold, makeGold, outPath, timePath, widths, timeLines, runColumns } = options;
        const fn = name + ".js";
        console.log(name);
        console.log("-".repeat(name.length));
        const command = exe + " -t benchmarks/" + fn + " >" + outPath + " 2>" + timePath;
        const timeSamples = [];
        const runValues = runColumns[name];
        let times = "";
        let mem1 = "";
        let mem2 = "";
        let mem3 = "";
        for (let i = 0; i < runs && times !== "FAIL"; ++i) {
                const result = child_process.spawnSync(command, { shell: true, stdio: "ignore" });
                if (result.error) throw result.error;
                times = fs.readFileSync(timePath, "utf8");
                if (times.trim() === "FAIL") {
                        times = "FAIL";
                } else {
                        const tokens = parseTimeOutput(times);
                        if (tokens.length === 0) throw new Error("No timing data captured.");
                        console.log(tokens[0]);
                        const raw = tokens[0].endsWith("s") ? tokens[0].slice(0, -1) : tokens[0];
                        const value = Number(raw);
                        if (!Number.isFinite(value)) throw new Error("Invalid timing output: " + tokens[0]);
                        timeSamples.push({ value, raw });
                        runValues.push(tokens[0]);
                        mem1 = tokens[1] || "";
                        mem2 = tokens[2] || "";
                        mem3 = tokens[3] || "";
                }
        }

        let output = fs.readFileSync(outPath, "utf8");
        output = normalizeOutput(output);
        const goldenFile = path.join("benchmarks", "golden", name + ".txt");
	if (makeGold) {
		fs.writeFileSync(goldenFile, output);
	} else if (!ignoreGold) {
		let expected = fs.readFileSync(goldenFile, "utf8");
		expected = normalizeOutput(expected);
		if (output !== expected) {
			times = "FAIL";
			fs.mkdirSync("output", { recursive: true });
			fs.writeFileSync(path.join("output", "failed.txt"), output);
			fs.writeFileSync(path.join("output", "expected.txt"), expected);
		}
	}

        const entries = timeLines[name];
        if (times === "FAIL") {
                console.log("\n!!! FAIL !!!\n");
                entries[0] = "FAIL";
                widths[name] = Math.max(widths[name], 4);
                return null;
        }

        if (timeSamples.length === 0) throw new Error("No timing data captured.");
	timeSamples.sort((a, b) => a.value - b.value);
	const mid = Math.floor(timeSamples.length / 2);
	let medianValue;
	let medianRaw;
	if (timeSamples.length % 2 !== 0) {
		medianValue = timeSamples[mid].value;
		medianRaw = timeSamples[mid].raw;
	} else {
		medianValue = (timeSamples[mid - 1].value + timeSamples[mid].value) / 2;
		medianRaw = formatNumber(medianValue);
	}
	const medianString = medianRaw + "s";
	entries[0] = medianString;
	entries[1] = mem1;
	entries[2] = mem2;
	entries[3] = mem3;
	for (const entry of entries) widths[name] = Math.max(widths[name], entry.length);
	console.log("median: " + medianString + "\n");
	return { value: medianValue, raw: medianRaw };
}

function collectBenchmarkNames(pattern) {
	const normalized = pattern.split("\\").join("/");
	const justName = normalized.split("/").pop();
	const regex = wildcardToRegExp(justName);
	const dirEntries = fs.readdirSync("benchmarks", { withFileTypes: true });
	const names = [];
	for (const entry of dirEntries) {
		if (!entry.isFile()) continue;
		if (!entry.name.endsWith(".js")) continue;
		if (regex.test(entry.name)) names.push(entry.name.slice(0, -3));
	}
	names.sort();
	return names;
}

function wildcardToRegExp(pattern) {
	let result = "^";
	for (let i = 0; i < pattern.length; ++i) {
		const ch = pattern[i];
		if (ch === "*") result += ".*";
		else if (ch === "?") result += ".";
		else if (ch === "/") result += "\/";
		else result += escapeRegExpChar(ch);
	}
	return new RegExp(result + "$", "i");
}

function escapeRegExpChar(ch) {
	return /[\^$+?.()|[\]{}]/.test(ch) ? "\\" + ch : ch;
}

function parseTimeOutput(text) {
	return text.replace(/\r\n/g, "\n").split(/\s+/).filter(Boolean);
}

function normalizeOutput(text) {
	let result = text.replace(/\r\n/g, "\n");
	while (result.endsWith("\n")) result = result.slice(0, -1);
	return result;
}

function buildSummaryLines(names, widths, timeLines) {
        const lines = [];
        lines[0] = "        ";
        lines[1] = "        ";
        const labels = ["median", "mem1", "mem2", "mem3"];
	for (let i = 0; i < labels.length; ++i) {
		lines[i + 2] = labels[i] + " ".repeat(8 - labels[i].length);
	}
	for (const name of names) {
		const width = widths[name];
		lines[0] += padColumn(name, width) + "  ";
		lines[1] += "-".repeat(width) + "  ";
		const entries = timeLines[name];
		for (let i = 0; i < 4; ++i) {
			const value = entries[i] || "";
			lines[i + 2] += padColumn(value, width) + "  ";
		}
        }
        return lines;
}

function buildFlippedLines(names, runColumns, timeLines) {
        const metricLabels = ["median", "mem1", "mem2", "mem3"];
        const headerLabel = "benchmark";
        let firstWidth = headerLabel.length;
        let maxRuns = 0;
        for (const name of names) {
                if (name.length > firstWidth) firstWidth = name.length;
                const runCount = runColumns[name].length;
                if (runCount > maxRuns) maxRuns = runCount;
        }
        const columnWidths = [firstWidth];
        const runHeaders = [];
        for (let i = 0; i < maxRuns; ++i) {
                const header = "run" + (i + 1);
                runHeaders.push(header);
                let width = header.length;
                for (const name of names) {
                        const value = runColumns[name][i] || "";
                        if (value.length > width) width = value.length;
                }
                columnWidths.push(width);
        }
        for (let i = 0; i < metricLabels.length; ++i) {
                const label = metricLabels[i];
                let width = label.length;
                for (const name of names) {
                        const entries = timeLines[name];
                        const value = entries[i] || "";
                        if (value.length > width) width = value.length;
                }
                columnWidths.push(width);
        }
        const headerValues = [headerLabel, ...runHeaders, ...metricLabels];
        const lines = [];
        lines.push(buildRow(headerValues, columnWidths));
        const separators = columnWidths.map(width => "-".repeat(width));
        lines.push(buildRow(separators, columnWidths));
        for (const name of names) {
                const values = [name];
                const runs = runColumns[name];
                for (let i = 0; i < maxRuns; ++i) {
                        values.push(runs[i] || "");
                }
                const entries = timeLines[name];
                for (let i = 0; i < metricLabels.length; ++i) {
                        values.push(entries[i] || "");
                }
                lines.push(buildRow(values, columnWidths));
        }
        return lines;
}

function buildRow(values, widths) {
        let line = "";
        for (let i = 0; i < widths.length; ++i) {
                if (i !== 0) line += "  ";
                line += padColumn(values[i], widths[i]);
        }
        return line;
}

function padColumn(value, width) {
        const text = value === undefined ? "" : String(value);
        const pad = Math.max(0, width - text.length);
        return text + " ".repeat(pad);
}

function formatNumber(value) {
	let text = String(value);
	if (text.indexOf("e") === -1 && text.indexOf("E") === -1 && text.indexOf(".") !== -1) {
		while (text.endsWith("0")) text = text.slice(0, -1);
		if (text.endsWith(".")) text = text.slice(0, -1);
	}
	return text;
}

function makeTempDir() {
	const prefix = path.join(os.tmpdir(), "NuXJS-benchmark-");
	return fs.mkdtempSync(prefix);
}

function cleanupTempDir(dir) {
	fs.rmSync(dir, { recursive: true, force: true });
}

try {
	main();
} catch (error) {
	const message = error && error.message ? error.message : String(error);
	console.log(message);
	process.exitCode = 1;
}

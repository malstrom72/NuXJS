#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

function listBenchmarkFiles(rootDir) {
	const benchDir = path.join(rootDir, "benchmarks");
	const entries = fs.readdirSync(benchDir, { withFileTypes: true });
	return entries
		.filter((entry) => entry.isFile() && entry.name.endsWith(".js"))
		.map((entry) => path.join("benchmarks", entry.name))
		.sort();
}

function runDisassembly(nuXJSPath, relativeFile, repoRoot) {
	const scriptLines = [];
	scriptLines.push("(function(){");
	scriptLines.push("	var originalPrint = print;");
	scriptLines.push("	function log(msg) { originalPrint(msg); }");
	scriptLines.push("	function snapshot() {");
	scriptLines.push("		var names = [];");
	scriptLines.push("		for (var key in this) names.push(key);");
	scriptLines.push("		return names;");
	scriptLines.push("	}");
	scriptLines.push("	function mapFrom(list) {");
	scriptLines.push("		var map = {};");
	scriptLines.push("		for (var i = 0; i < list.length; ++i) map[list[i]] = true;");
	scriptLines.push("		return map;");
	scriptLines.push("	}");
	scriptLines.push("	var file = " + JSON.stringify(relativeFile) + ";");
	scriptLines.push("	log('@@FILE ' + file);");
	scriptLines.push("	var before = snapshot();");
	scriptLines.push("	var beforeMap = mapFrom(before);");
	scriptLines.push("	var suppressedPrint = function() {};");
	scriptLines.push("	var savedPrint = print;");
	scriptLines.push("	print = suppressedPrint;");
	scriptLines.push("	var loadError = null;");
	scriptLines.push("	try {");
	scriptLines.push("		load(file);");
	scriptLines.push("	} catch (e) {");
	scriptLines.push("		loadError = e;");
	scriptLines.push("	}");
	scriptLines.push("	print = savedPrint;");
	scriptLines.push("	if (loadError) {");
	scriptLines.push("		log('@@ERROR ' + file + ' ' + loadError);");
	scriptLines.push("		quit();");
	scriptLines.push("		return;");
	scriptLines.push("	}");
	scriptLines.push("	var after = snapshot();");
	scriptLines.push("	var newNames = [];");
	scriptLines.push("	for (var i = 0; i < after.length; ++i) {");
	scriptLines.push("		var name = after[i];");
	scriptLines.push("		if (!beforeMap[name]) newNames.push(name);");
	scriptLines.push("	}");
	scriptLines.push("	var globalObject = this;");
	scriptLines.push("	function seen(list, value) {");
	scriptLines.push("		for (var i = 0; i < list.length; ++i) {");
	scriptLines.push("			if (list[i] === value) return true;");
	scriptLines.push("		}");
	scriptLines.push("		return false;");
	scriptLines.push("	}");
	scriptLines.push("	var hop = Object.prototype.hasOwnProperty;");
	scriptLines.push("	function hasOwn(obj, key) {");
	scriptLines.push("		try { return hop.call(obj, key); } catch (e) { return false; }");
	scriptLines.push("	}");
	scriptLines.push("	function appendPath(base, key) {");
	scriptLines.push("		var ident = /^[A-Za-z_$][0-9A-Za-z_$]*$/.test(key);");
	scriptLines.push("		var numeric = /^[0-9]+$/.test(key);");
	scriptLines.push("		if (!base || base === '') {");
	scriptLines.push("			if (ident) return key;");
	scriptLines.push("			if (numeric) return '[' + key + ']';");
	scriptLines.push("			return '[' + JSON.stringify(key) + ']';");
	scriptLines.push("		}");
	scriptLines.push("		if (ident) return base + '.' + key;");
	scriptLines.push("		if (numeric) return base + '[' + key + ']';");
	scriptLines.push("		return base + '[' + JSON.stringify(key) + ']';");
	scriptLines.push("	}");
	scriptLines.push("	function collectFunctions(name, value, collected, seenFunctions, seenObjects) {");
	scriptLines.push("		if (value === undefined || value === null) {");
	scriptLines.push("			return;");
	scriptLines.push("		}");
	scriptLines.push("		if (typeof value === 'function') {");
	scriptLines.push("			if (!seen(seenFunctions, value)) {");
	scriptLines.push("				seenFunctions.push(value);");
	scriptLines.push("				collected.push({ name: name || '(anonymous)', value: value });");
	scriptLines.push("			}");
	scriptLines.push("			return;");
	scriptLines.push("		}");
	scriptLines.push("		if (typeof value !== 'object') {");
	scriptLines.push("			return;");
	scriptLines.push("		}");
	scriptLines.push("		if (value === globalObject) {");
	scriptLines.push("			return;");
	scriptLines.push("		}");
	scriptLines.push("		if (seen(seenObjects, value)) {");
	scriptLines.push("			return;");
	scriptLines.push("		}");
	scriptLines.push("		seenObjects.push(value);");
	scriptLines.push("		var length = value.length;");
	scriptLines.push("		if (typeof length === 'number' && length > 512) {");
	scriptLines.push("			return;");
	scriptLines.push("		}");
	scriptLines.push("		var keys = [];");
	scriptLines.push("		for (var key in value) {");
	scriptLines.push("			if (hasOwn(value, key)) keys.push(key);");
	scriptLines.push("		}");
	scriptLines.push("		keys.sort();");
	scriptLines.push("		for (var i = 0; i < keys.length; ++i) {");
	scriptLines.push("			var key = keys[i];");
	scriptLines.push("			var child;");
	scriptLines.push("			try {");
	scriptLines.push("				child = value[key];");
	scriptLines.push("			} catch (err) {");
	scriptLines.push("				continue;");
	scriptLines.push("			}");
	scriptLines.push("			var childName = appendPath(name, key);");
	scriptLines.push("			collectFunctions(childName, child, collected, seenFunctions, seenObjects);");
	scriptLines.push("		}");
	scriptLines.push("	}");
	scriptLines.push("	var collected = [];");
	scriptLines.push("	var seenFunctions = [];");
	scriptLines.push("	var seenObjects = [];");
	scriptLines.push("	for (var j = 0; j < newNames.length; ++j) {");
	scriptLines.push("		var name = newNames[j];");
	scriptLines.push("		var value = this[name];");
	scriptLines.push("		collectFunctions(name, value, collected, seenFunctions, seenObjects);");
	scriptLines.push("	}");
	scriptLines.push("	collected.sort(function(a, b) {");
	scriptLines.push("		if (a.name < b.name) return -1;");
	scriptLines.push("		if (a.name > b.name) return 1;");
	scriptLines.push("		return 0;");
	scriptLines.push("	});");
	scriptLines.push("	for (var idx = 0; idx < collected.length; ++idx) {");
	scriptLines.push("		var entry = collected[idx];");
	scriptLines.push("		log('@@FUNCTION ' + entry.name);");
	scriptLines.push("		dasm(entry.value);");
	scriptLines.push("	}");
	scriptLines.push("	log('@@END_FILE');");
	scriptLines.push("	quit();");
	scriptLines.push("})();");
	scriptLines.push("");

	const joinedScript = scriptLines.join("\n");
	const options = {
		encoding: "utf8",
		input: joinedScript,
		cwd: repoRoot,
		timeout: 240000
	};
	const result = spawnSync(nuXJSPath, [], options);
	if (result.error) {
		throw result.error;
	}
	if (result.status !== 0) {
		throw new Error(`NuXJS exit code ${result.status} for ${relativeFile}: ${result.stderr}`);
	}
	return {
		markers: result.stdout || "",
		body: result.stderr || ""
	};
}

function parseDisassembly(rawOutput) {
	const markerLines = rawOutput.markers.split(/\r?\n/);
	const bodyLines = rawOutput.body ? rawOutput.body.split(/\r?\n/) : [];
	const fileData = { functions: [], errors: [] };
	const chunks = [];
	let chunk = [];
	for (let i = 0; i < bodyLines.length; ++i) {
		const entry = bodyLines[i];
		if (!entry || entry.trim() === "") {
			continue;
		}
		if (entry.indexOf("=undefined") !== -1) {
			if (chunk.length > 0) {
				chunks.push(chunk);
				chunk = [];
			}
			continue;
		}
		chunk.push(entry);
	}
	if (chunk.length > 0) {
		chunks.push(chunk);
	}
	let chunkIndex = 0;
	let current = null;
	for (let i = 0; i < markerLines.length; ++i) {
		const line = markerLines[i];
		if (!line) {
			continue;
		}
		if (line.startsWith("@@FILE ")) {
			fileData.file = line.substring(7).trim();
		} else if (line.startsWith("@@ERROR ")) {
			fileData.errors.push(line.substring(8).trim());
		} else if (line.startsWith("@@FUNCTION ")) {
			if (current) {
				if (chunkIndex < chunks.length) {
					current.lines = chunks[chunkIndex++];
				}
				fileData.functions.push(current);
			}
			current = { name: line.substring(11).trim(), lines: [] };
		} else if (line.startsWith("@@END_FILE")) {
			if (current) {
				if (chunkIndex < chunks.length) {
					current.lines = chunks[chunkIndex++];
				}
				fileData.functions.push(current);
				current = null;
			}
		}
	}
	if (current) {
		if (chunkIndex < chunks.length) {
			current.lines = chunks[chunkIndex++];
		}
		fileData.functions.push(current);
	}
	return fileData;
}

function extractOpcodes(functionInfo) {
	const ops = [];
	for (let i = 0; i < functionInfo.lines.length; ++i) {
		const line = functionInfo.lines[i].trim();
		if (!line) {
			continue;
		}
		const match = line.match(/^[0-9]+\s+@[^:]+:\s+([A-Z0-9_]+)/);
		if (match) {
			ops.push(match[1]);
		}
	}
	return ops;
}

function updateCounts(map, key) {
	if (!map[key]) {
		map[key] = 0;
	}
	map[key] += 1;
}

function formatTable(map, header1, header2) {
	const entries = Object.keys(map)
		.map((key) => ({ key, count: map[key] }))
		.sort((a, b) => b.count - a.count || a.key.localeCompare(b.key));
	const lines = [];
	lines.push(`| ${header1} | ${header2} |`);
	lines.push("| --- | ---: |");
	for (let i = 0; i < entries.length; ++i) {
		lines.push(`| ${entries[i].key} | ${entries[i].count} |`);
	}
	if (entries.length === 0) {
		lines.push("| _(none)_ | 0 |");
	}
	return lines.join("\n");
}

function buildDocument(repoRoot, fileReports, singleOps, pairOps, tripleOps) {
	const docLines = [];
	docLines.push("# NuXJS Benchmark Bytecode Disassembly");
	docLines.push("");
	docLines.push("This report captures the NuXJS bytecode generated for the benchmark suite and summarises opcode usage patterns.");
	docLines.push("The disassembly data was collected with `dasm()` through the NuXJS REPL while suppressing benchmark printing side-effects.");
	docLines.push("");
	docLines.push("## Aggregate opcode usage");
	docLines.push("");
	docLines.push(formatTable(singleOps, "Opcode", "Count"));
	docLines.push("");
	docLines.push("### Adjacent opcode pairs");
	docLines.push("");
	docLines.push(formatTable(pairOps, "Opcode pair", "Count"));
	docLines.push("");
	docLines.push("### Adjacent opcode triples");
	docLines.push("");
	docLines.push(formatTable(tripleOps, "Opcode triple", "Count"));
	docLines.push("");
	for (let i = 0; i < fileReports.length; ++i) {
		const report = fileReports[i];
		docLines.push(`## ${report.file}`);
		docLines.push("");
		if (report.errors.length > 0) {
			docLines.push("**Errors:**");
			for (let j = 0; j < report.errors.length; ++j) {
				docLines.push(`- ${report.errors[j]}`);
			}
			docLines.push("");
		}
		if (report.functions.length === 0) {
			docLines.push("_No global functions discovered in this benchmark._");
			docLines.push("");
			continue;
		}
		for (let j = 0; j < report.functions.length; ++j) {
			const func = report.functions[j];
			docLines.push(`### ${func.name}`);
			docLines.push("");
			docLines.push("```");
			docLines.push(func.lines.join("\n"));
			docLines.push("```");
			docLines.push("");
		}
	}
	const outputPath = path.join(repoRoot, "docs", "nuxjs_benchmark_bytecode.md");
	fs.writeFileSync(outputPath, docLines.join("\n") + "\n", "utf8");
}

function main() {
	const repoRoot = path.resolve(__dirname, "..");
	const nuXJSPath = path.join(repoRoot, "output", "NuXJS");
	if (!fs.existsSync(nuXJSPath)) {
		throw new Error("NuXJS binary not found. Run build.sh before generating the report.");
	}
	const files = listBenchmarkFiles(repoRoot).map((file) => file.trim());
	const reports = [];
	const singleOps = {};
	const pairOps = {};
	const tripleOps = {};
	for (let i = 0; i < files.length; ++i) {
		const file = files[i];
		process.stderr.write(`Disassembling ${file}\n`);
		const output = runDisassembly(nuXJSPath, file, repoRoot);
		const report = parseDisassembly(output);
		if (i === 0) {
		}
		for (let j = 0; j < report.functions.length; ++j) {
			const fn = report.functions[j];
			const ops = extractOpcodes(fn);
			for (let k = 0; k < ops.length; ++k) {
				updateCounts(singleOps, ops[k]);
			}
			for (let k = 0; k + 1 < ops.length; ++k) {
				const pairKey = `${ops[k]} → ${ops[k + 1]}`;
				updateCounts(pairOps, pairKey);
			}
			for (let k = 0; k + 2 < ops.length; ++k) {
				const tripleKey = `${ops[k]} → ${ops[k + 1]} → ${ops[k + 2]}`;
				updateCounts(tripleOps, tripleKey);
			}
		}
		reports.push(report);
	}
	buildDocument(repoRoot, reports, singleOps, pairOps, tripleOps);
}

main();

#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const DESIRED_ORDER = __ORDER_ARRAY__;

const TARGET_FILE = path.resolve(__dirname, "__RELATIVE_TARGET__");

function findSwitchBounds(source) {
	const marker = "switch (opcode)";
	const index = source.indexOf(marker);
	if (index === -1) {
		return null;
	}
	let openIndex = source.indexOf("{", index);
	if (openIndex === -1) {
		return null;
	}
	let depth = 0;
	let inSingleQuote = false;
	let inDoubleQuote = false;
	let inLineComment = false;
	let inBlockComment = false;
	let escape = false;
	for (let i = openIndex; i < source.length; ++i) {
		const ch = source[i];
		const next = i + 1 < source.length ? source[i + 1] : "";
		const prev = i > 0 ? source[i - 1] : "";
		if (inLineComment) {
			if (ch === "\n") {
				inLineComment = false;
			}
			continue;
		}
		if (inBlockComment) {
			if (prev === "*" && ch === "/") {
				inBlockComment = false;
			}
			continue;
		}
		if (inDoubleQuote) {
			if (!escape && ch === '"') {
				inDoubleQuote = false;
			}
			escape = !escape && ch === '\\';
			continue;
		}
		if (inSingleQuote) {
			if (!escape && ch === "'") {
				inSingleQuote = false;
			}
			escape = !escape && ch === '\\';
			continue;
		}
		escape = false;
		if (ch === "/" && next === "/") {
			inLineComment = true;
			++i;
			continue;
		}
		if (ch === "/" && next === "*") {
			inBlockComment = true;
			++i;
			continue;
		}
		if (ch === '"') {
			inDoubleQuote = true;
			continue;
		}
		if (ch === "'") {
			inSingleQuote = true;
			continue;
		}
		if (ch === "{") {
			++depth;
			continue;
		}
		if (ch === "}") {
			--depth;
			if (depth === 0) {
				return { start: openIndex + 1, end: i };
			}
			continue;
		}
	}
	return null;
}

function splitSwitchCases(block) {
	const lines = block.split("\n");
	const prefix = [];
	const cases = [];
	let current = null;
	let seenCase = false;

	function startEntry() {
		return { labels: [], lines: [], hasBody: false };
	}

	for (const line of lines) {
		const caseMatch = line.match(/^\s*case\s+([A-Z0-9_]+)\s*:/);
		const defaultMatch = line.match(/^\s*default\s*:/);
		if (caseMatch || defaultMatch) {
			const label = caseMatch ? caseMatch[1] : "default";
			const colonIndex = line.indexOf(":");
			let inlineBody = false;
			if (colonIndex !== -1) {
				const after = line.slice(colonIndex + 1).trim();
				if (after.length !== 0 && !after.startsWith("//") && !after.startsWith("/*")) {
					inlineBody = true;
				}
			}
			if (!seenCase) {
				seenCase = true;
			}
			if (current === null || current.hasBody) {
				if (current) {
					cases.push(current);
				}
				current = startEntry();
			}
			current.labels.push(label);
			current.lines.push(line);
			if (inlineBody) {
				current.hasBody = true;
			}
			continue;
		}
		if (!seenCase) {
			prefix.push(line);
			continue;
		}
		if (current === null) {
			current = startEntry();
		}
		const trimmed = line.trim();
		if (trimmed.length !== 0 && !trimmed.startsWith("//") && !trimmed.startsWith("/*") && !trimmed.startsWith("*") && !trimmed.startsWith("*/")) {
			current.hasBody = true;
		}
		current.lines.push(line);
	}
	if (current) {
		cases.push(current);
	}
	return { prefix, cases, trailingNewline: block.endsWith("\n") };
}

function reorderCases(existingCases, desiredOrder) {
	const labelToEntry = new Map();
	const ordered = [];
	const seenEntries = new Set();
	const remaining = [];
	let defaultCase = null;
	for (const entry of existingCases) {
		if (entry.labels.includes("default")) {
			defaultCase = entry;
			continue;
		}
		remaining.push(entry);
		for (const label of entry.labels) {
			labelToEntry.set(label, entry);
		}
	}
	for (const label of desiredOrder) {
		const entry = labelToEntry.get(label);
		if (entry && !seenEntries.has(entry)) {
			ordered.push(entry);
			seenEntries.add(entry);
		}
	}
	for (const entry of remaining) {
		if (!seenEntries.has(entry)) {
			ordered.push(entry);
			seenEntries.add(entry);
		}
	}
	if (defaultCase) {
		ordered.push(defaultCase);
	}
	return ordered;
}
function renderSwitchBlock(prefix, cases, trailingNewline) {
	const lines = prefix.slice();
	for (const entry of cases) {
		lines.push(...entry.lines);
	}
	let output = lines.join("\n");
	if (trailingNewline) {
		output += "\n";
	}
	return output;
}

function rewriteSourceWithOrder(source, order) {
	const bounds = findSwitchBounds(source);
	if (!bounds) {
		return null;
	}
	const block = source.slice(bounds.start, bounds.end);
	const parts = splitSwitchCases(block);
	if (parts.cases.length === 0) {
		return null;
	}
	const reordered = reorderCases(parts.cases, order);
	const rewrittenBlock = renderSwitchBlock(parts.prefix, reordered, parts.trailingNewline);
	return source.slice(0, bounds.start) + rewrittenBlock + source.slice(bounds.end);
}

function main() {
	const args = process.argv.slice(2);
	let checkOnly = false;
	for (const arg of args) {
		if (arg === "--check") {
			checkOnly = true;
		} else {
			console.error("Unknown argument: " + arg);
			process.exit(1);
		}
	}
	let original;
	try {
		original = fs.readFileSync(TARGET_FILE, "utf8");
	} catch (error) {
		console.error("Failed to read " + TARGET_FILE + ": " + error.message);
		process.exit(1);
	}
	const rewritten = rewriteSourceWithOrder(original, DESIRED_ORDER);
	if (rewritten === null) {
		console.error("Unable to locate Processor::innerRun switch block.");
		process.exit(1);
	}
	if (rewritten === original) {
		if (!checkOnly) {
			console.log("Processor::innerRun already matches the desired opcode order.");
		}
		return;
	}
	if (checkOnly) {
		console.error("Processor::innerRun differs from the desired opcode order.");
		process.exit(1);
	}
	fs.writeFileSync(TARGET_FILE, rewritten, "utf8");
	console.log("Reordered switch cases in " + TARGET_FILE);
}

main();

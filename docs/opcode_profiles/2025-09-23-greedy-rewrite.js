#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const DESIRED_ORDER = [
	"SET_PROPERTY_OP",
	"X_EQ_OP",
	"NEW_RESULT_OP",
	"MINUS_OP",
	"JT_OR_POP_OP",
	"PUSH_ELEMENTS_OP",
	"PRE_EQ_OP",
	"NEW_ARRAY_OP",
	"EQ_OP",
	"DECLARE_OP",
	"READ_LOCAL_TO_PRIMITIVE_OP",
	"ADD_OP",
	"THIS_OP",
	"SUB_OP",
	"WRITE_LOCAL_OP",
	"NEW_OBJECT_OP",
	"GET_ENUMERATOR_OP",
	"GEQ_OP",
	"LEQ_OP",
	"GEN_FUNC_OP",
	"SET_PROPERTY_POP_OP",
	"REPUSH_2_OP",
	"REPUSH_OP",
	"NEXT_PROPERTY_OP",
	"INC_OP",
	"PUSH_BACK_OP",
	"LT_OP",
	"JF_OP",
	"CHECK_OBJECT_COERCIBLE_OP",
	"AND_OP",
	"WRITE_NAMED_POP_OP",
	"READ_LOCAL_OP",
	"RETURN_OP",
	"XOR_OP",
	"TYPEOF_NAMED_OP",
	"POP_OP",
	"READ_NAMED_OP",
	"OBJ_TO_NUMBER_OP",
	"WRITE_LOCAL_POP_OP",
	"READ_LOCAL_TO_NUMBER_OP",
	"CONST_OP",
	"USHR_OP",
	"OR_OP",
	"VOID_OP",
	"SHL_OP",
	"CALL_OP",
	"GT_OP",
	"JT_OP",
	"CALL_METHOD_OP",
	"JMP_OP",
	"OBJ_TO_STRING_OP",
	"GET_PROPERTY_OP",
	"CHECK_RESOLVE_PROPERTY_OP",
	"X_NEQ_OP",
	"ADD_PROPERTY_OP",
	"JF_OR_POP_OP",
	"DEC_OP",
	"NEW_OP",
	"CALL_EVAL_OP",
	"CATCH_SCOPE_OP",
	"DELETE_OP",
	"DELETE_NAMED_OP",
	"DIV_OP",
	"IN_OP",
	"INSTANCE_OF_OP",
	"INV_OP",
	"JSR_OP",
	"MOD_OP",
	"MUL_OP",
	"NEQ_OP",
	"NEW_REG_EXP_OP",
	"NOT_OP",
	"OBJ_TO_PRIMITIVE_OP",
	"PLUS_OP",
	"POP_FRAME_OP",
	"POST_SHUFFLE_OP",
	"READ_LOCAL_TO_STRING_OP",
	"SHR_OP",
	"SWAP_OP",
	"THROW_OP",
	"TRIED_OP",
	"TRY_OP",
	"TYPEOF_OP",
	"WITH_SCOPE_OP",
	"WRITE_NAMED_OP"
];

const TARGET_FILE = path.resolve(__dirname, "../../src/NuXJS.cpp");

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
                        if (!escape && ch === "\"") {
				inDoubleQuote = false;
			}
			escape = !escape && ch === "\\";
			continue;
		}
		if (inSingleQuote) {
			if (!escape && ch === "'") {
				inSingleQuote = false;
			}
			escape = !escape && ch === "\\";
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
                if (ch === "\"") {
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
	for (const line of lines) {
		const caseMatch = line.match(/^\s*case\s+([A-Z0-9_]+)\s*:/);
		const defaultMatch = line.match(/^\s*default\s*:/);
		if (caseMatch || defaultMatch) {
			if (current) {
				cases.push(current);
			}
			seenCase = true;
			const label = caseMatch ? caseMatch[1] : "default";
			current = { label, lines: [] };
		}
		if (!seenCase) {
			prefix.push(line);
		} else if (current) {
			current.lines.push(line);
		}
	}
	if (current) {
		cases.push(current);
	}
	return { prefix, cases, trailingNewline: block.endsWith("\n") };
}

function reorderCases(existingCases, desiredOrder) {
	const map = new Map();
	const existingOrder = [];
	let defaultCase = null;
	for (const entry of existingCases) {
		if (entry.label === "default") {
			defaultCase = entry;
			continue;
		}
		map.set(entry.label, entry);
		existingOrder.push(entry.label);
	}
	const ordered = [];
	const seen = new Set();
	for (const label of desiredOrder) {
		if (map.has(label) && !seen.has(label)) {
			ordered.push(map.get(label));
			seen.add(label);
		}
	}
	for (const label of existingOrder) {
		if (!seen.has(label)) {
			ordered.push(map.get(label));
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

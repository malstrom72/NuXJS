#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

function usage() {
const message = [
"Usage: analyze_opcode_profile <profile.json> [--report=path] [--dot=path] [--top=N] [--order=path]",
"",
"Reads a dynamic opcode profile captured by the instrumentation and emits",
"summaries of opcode hotness plus transition probabilities. Optionally writes",
"a Graphviz .dot file describing the hottest transitions and a greedy",
"Pettis–Hansen-style opcode order derived from the observed transitions."
].join("\n");
console.error(message);
}

function parseArgs(argv) {
let input = null;
let reportPath = null;
let dotPath = null;
let orderPath = null;
let topN = 20;

	for (let i = 2; i < argv.length; ++i) {
		const arg = argv[i];
		if (arg === "-h" || arg === "--help") {
			usage();
			process.exit(0);
		} else if (arg.startsWith("--report=")) {
			reportPath = arg.substring("--report=".length);
		} else if (arg.startsWith("--dot=")) {
			dotPath = arg.substring("--dot=".length);
} else if (arg.startsWith("--top=")) {
const value = parseInt(arg.substring("--top=".length), 10);
if (!Number.isFinite(value) || value <= 0) {
throw new Error("--top must be a positive integer");
}
topN = value;
} else if (arg.startsWith("--order=")) {
orderPath = arg.substring("--order=".length);
} else if (arg.startsWith("--")) {
throw new Error("Unknown option: " + arg);
} else if (input === null) {
input = arg;
} else {
throw new Error("Unexpected argument: " + arg);
}
}

if (input === null) {
throw new Error("Missing input profile path");
}

return { input, reportPath, dotPath, orderPath, topN };
}

function loadProfile(filePath) {
	const resolved = path.resolve(process.cwd(), filePath);
	const raw = fs.readFileSync(resolved, "utf8");
	const profile = JSON.parse(raw);
	if (!profile || !Array.isArray(profile.opcodes) || !Array.isArray(profile.transitions)) {
		throw new Error("Profile JSON must contain 'opcodes' and 'transitions' arrays");
	}
	return profile;
}

function buildGraph(profile) {
	const opcodeCounts = new Map();
	let totalOpcodes = 0;
	for (const entry of profile.opcodes) {
		if (!entry || typeof entry.opcode !== "string") {
			continue;
		}
		const count = Number(entry.count) || 0;
		opcodeCounts.set(entry.opcode, count);
		totalOpcodes += count;
	}

	const transitions = new Map();
	let totalTransitions = 0;
	for (const edge of profile.transitions) {
		if (!edge || typeof edge.from !== "string" || typeof edge.to !== "string") {
			continue;
		}
		const count = Number(edge.count) || 0;
		totalTransitions += count;
		if (!transitions.has(edge.from)) {
			transitions.set(edge.from, new Map());
		}
		const map = transitions.get(edge.from);
		map.set(edge.to, (map.get(edge.to) || 0) + count);
	}

	const fromTotals = new Map();
	transitions.forEach((targets, from) => {
		let sum = 0;
		targets.forEach((value) => { sum += value; });
		fromTotals.set(from, sum);
	});

	return { opcodeCounts, totalOpcodes, transitions, fromTotals, totalTransitions };
}

function formatCount(value) {
	return new Intl.NumberFormat("en-US").format(value);
}

function formatPercent(numerator, denominator) {
	if (!denominator) {
		return "0.00%";
	}
	return ((numerator / denominator) * 100).toFixed(2) + "%";
}

function formatProbability(value) {
	return value.toFixed(4);
}

function collectTopOpCodes(opcodeCounts) {
	return Array.from(opcodeCounts.entries())
		.sort((a, b) => b[1] - a[1]);
}

function collectTopEdges(graph) {
	const edges = [];
	graph.transitions.forEach((targets, from) => {
		const fromTotal = graph.fromTotals.get(from) || 0;
		targets.forEach((count, to) => {
			const probability = fromTotal ? count / fromTotal : 0;
			edges.push({ from, to, count, probability });
		});
	});
	edges.sort((a, b) => {
		if (b.count !== a.count) return b.count - a.count;
		if (b.probability !== a.probability) return b.probability - a.probability;
		if (a.from !== b.from) return a.from < b.from ? -1 : 1;
		return a.to < b.to ? -1 : 1;
	});
	return edges;
}

function ensureCluster(graph, opcode, clusterMap, clusterList) {
	if (clusterMap.has(opcode)) {
		return clusterMap.get(opcode);
	}
	const cluster = {
		nodes: [opcode],
		entryCount: graph.opcodeCounts.get(opcode) || 0,
		active: true
	};
	clusterMap.set(opcode, cluster);
	clusterList.push(cluster);
	return cluster;
}

function computeClusterGain(graph, fromCluster, toCluster) {
	let gain = 0;
	for (const source of fromCluster.nodes) {
		const targets = graph.transitions.get(source);
		if (!targets) {
			continue;
		}
		for (const target of toCluster.nodes) {
			gain += targets.get(target) || 0;
		}
	}
	return gain;
}

function mergeClusters(clusterMap, left, right) {
	if (!left.active || !right.active) {
		return;
	}
	for (const opcode of right.nodes) {
		clusterMap.set(opcode, left);
	}
	left.nodes = left.nodes.concat(right.nodes);
	left.entryCount += right.entryCount;
	right.active = false;
}

function computeClusterInternalWeight(graph, cluster) {
	let weight = 0;
	for (const source of cluster.nodes) {
		const targets = graph.transitions.get(source);
		if (!targets) {
			continue;
		}
		for (const target of cluster.nodes) {
			weight += targets.get(target) || 0;
		}
	}
	return weight;
}

function computeSequentialCoverage(graph, order) {
	let weight = 0;
	for (let i = 0; i < order.length - 1; ++i) {
		const from = order[i];
		const to = order[i + 1];
		const targets = graph.transitions.get(from);
		if (targets && targets.has(to)) {
			weight += targets.get(to);
		}
	}
	return weight;
}

function buildGreedyClusters(graph) {
	const clusterMap = new Map();
	const clusterList = [];
	graph.opcodeCounts.forEach((_, opcode) => {
		ensureCluster(graph, opcode, clusterMap, clusterList);
	});
	graph.transitions.forEach((targets, from) => {
		const fromCluster = ensureCluster(graph, from, clusterMap, clusterList);
		targets.forEach((_, to) => {
			ensureCluster(graph, to, clusterMap, clusterList);
		});
		clusterMap.set(from, fromCluster);
	});

	const edges = collectTopEdges(graph);
	for (const edge of edges) {
		const fromCluster = clusterMap.get(edge.from);
		const toCluster = clusterMap.get(edge.to);
		if (!fromCluster || !toCluster || fromCluster === toCluster) {
			continue;
		}
		const forwardGain = computeClusterGain(graph, fromCluster, toCluster);
		const backwardGain = computeClusterGain(graph, toCluster, fromCluster);
		if (forwardGain === 0 && backwardGain === 0) {
			continue;
		}
		if (forwardGain >= backwardGain) {
			mergeClusters(clusterMap, fromCluster, toCluster);
		} else {
			mergeClusters(clusterMap, toCluster, fromCluster);
		}
	}

	const activeClusters = clusterList.filter((cluster) => cluster.active);
	activeClusters.sort((a, b) => {
		if (b.entryCount !== a.entryCount) {
			return b.entryCount - a.entryCount;
		}
		return a.nodes[0] < b.nodes[0] ? -1 : 1;
	});

	const order = [];
	const clusterSummaries = [];
	for (const cluster of activeClusters) {
		const internalWeight = computeClusterInternalWeight(graph, cluster);
		clusterSummaries.push({
			nodes: cluster.nodes.slice(),
			entryCount: cluster.entryCount,
			internalWeight
		});
		for (const opcode of cluster.nodes) {
			order.push(opcode);
		}
	}

	const clusterCoverage = clusterSummaries.reduce((sum, info) => sum + info.internalWeight, 0);
	const sequentialCoverage = computeSequentialCoverage(graph, order);

	return {
		clusters: clusterSummaries,
		order,
		clusterCoverage,
		sequentialCoverage
	};
}

function renderMatrix(graph, topOpNames) {
	const header = ["From/To"].concat(topOpNames);
	const rows = [header];
	for (const from of topOpNames) {
		const row = [from];
		const targets = graph.transitions.get(from);
		const fromTotal = graph.fromTotals.get(from) || 0;
		for (const to of topOpNames) {
			let prob = 0;
			if (targets && targets.has(to) && fromTotal) {
				prob = targets.get(to) / fromTotal;
			}
			row.push(prob);
		}
		rows.push(row);
	}
	return rows;
}

function tableToMarkdown(table) {
	if (table.length === 0) {
		return "";
	}
	const header = table[0];
	const lines = [];
	lines.push("| " + header.map((value) => value).join(" | ") + " |");
	lines.push("| " + header.map(() => "---").join(" | ") + " |");
	for (let i = 1; i < table.length; ++i) {
		const row = table[i].map((value, index) => {
			if (index === 0) {
				return value;
			}
			return formatProbability(value);
		});
		lines.push("| " + row.join(" | ") + " |");
	}
	return lines.join("\n");
}

function buildReport(graph, topN, clustering) {
	const lines = [];
	lines.push("# Opcode Profile Summary");
	lines.push("");
	lines.push("Total opcode executions: " + formatCount(graph.totalOpcodes));
	lines.push("Total recorded transitions: " + formatCount(graph.totalTransitions));
	lines.push("");

	const sortedOps = collectTopOpCodes(graph.opcodeCounts);
	lines.push("## Hottest opcodes");
	lines.push("");
	lines.push("| Rank | Opcode | Count | Share |");
	lines.push("| --- | --- | ---: | ---: |");
	for (let i = 0; i < Math.min(topN, sortedOps.length); ++i) {
		const [opcode, count] = sortedOps[i];
		lines.push("| " + (i + 1) + " | " + opcode + " | " + formatCount(count) + " | " + formatPercent(count, graph.totalOpcodes) + " |");
	}
	lines.push("");

	const edges = collectTopEdges(graph);
	lines.push("## Hottest transitions");
	lines.push("");
	lines.push("| Rank | From | To | Count | P(Next) |");
	lines.push("| --- | --- | --- | ---: | ---: |");
	for (let i = 0; i < Math.min(topN, edges.length); ++i) {
		const edge = edges[i];
		lines.push("| " + (i + 1) + " | " + edge.from + " | " + edge.to + " | " + formatCount(edge.count) + " | " + formatProbability(edge.probability) + " |");
	}
	lines.push("");

	lines.push("## Top successors per opcode");
	lines.push("");
	const maxSuccessors = 5;
	for (let i = 0; i < Math.min(topN, sortedOps.length); ++i) {
		const opcode = sortedOps[i][0];
		const targets = graph.transitions.get(opcode);
		const fromTotal = graph.fromTotals.get(opcode) || 0;
		lines.push("### " + opcode + " (" + formatCount(fromTotal) + " transitions)");
		if (!targets || targets.size === 0) {
			lines.push("No recorded successors.");
			lines.push("");
			continue;
		}
		const sortedTargets = Array.from(targets.entries())
		.sort((a, b) => b[1] - a[1]);
		lines.push("| Rank | Successor | Count | P(Next) |");
		lines.push("| --- | --- | ---: | ---: |");
		for (let j = 0; j < Math.min(maxSuccessors, sortedTargets.length); ++j) {
			const [successor, count] = sortedTargets[j];
			lines.push("| " + (j + 1) + " | " + successor + " | " + formatCount(count) + " | " + formatProbability(fromTotal ? count / fromTotal : 0) + " |");
		}
		lines.push("");
	}

	const matrixSize = Math.min(10, sortedOps.length);
	const topNames = sortedOps.slice(0, matrixSize).map((entry) => entry[0]);
	lines.push("## Transition probability matrix (top " + matrixSize + " opcodes)");
	lines.push("");
	lines.push(tableToMarkdown(renderMatrix(graph, topNames)));
	lines.push("");

	if (clustering) {
		lines.push("## Greedy clustering candidate layout");
		lines.push("");
		lines.push("Covered transitions inside clusters: " + formatCount(clustering.clusterCoverage)
		+ " (" + formatPercent(clustering.clusterCoverage, graph.totalTransitions) + ")");
		lines.push("Covered transitions between sequential opcodes in the flattened order: "
		+ formatCount(clustering.sequentialCoverage) + " ("
		+ formatPercent(clustering.sequentialCoverage, graph.totalTransitions) + ")");
		lines.push("");
		for (let i = 0; i < clustering.clusters.length; ++i) {
			const cluster = clustering.clusters[i];
			lines.push("### Cluster " + (i + 1) + " (" + cluster.nodes.length + " opcodes)");
			lines.push("");
			lines.push("- Entry executions: " + formatCount(cluster.entryCount));
			lines.push("- Internal transition weight: " + formatCount(cluster.internalWeight) + " ("
			+ formatPercent(cluster.internalWeight, graph.totalTransitions) + ")");
			lines.push("");
			lines.push(cluster.nodes.map((opcode) => "`" + opcode + "`").join(", "));
			lines.push("");
		}
		lines.push("### Flattened opcode order");
		lines.push("");
		lines.push("| Position | Opcode |");
		lines.push("| ---: | --- |");
		for (let i = 0; i < clustering.order.length; ++i) {
			lines.push("| " + (i + 1) + " | " + clustering.order[i] + " |");
		}
		lines.push("");
	}

	return lines.join("\n");
}

function buildDot(graph, edges, limit) {
	const selected = edges.slice(0, limit);
	const nodeSet = new Set();
	for (const edge of selected) {
		nodeSet.add(edge.from);
		nodeSet.add(edge.to);
	}
	const lines = [];
	lines.push("digraph opcode_transitions {");
	lines.push("\trankdir=LR;");
	lines.push("\tnode [shape=box, style=filled, fillcolor=\"#eef5ff\"];");
	for (const node of nodeSet) {
		lines.push("\t" + JSON.stringify(node) + ";");
	}
	for (const edge of selected) {
		const label = formatCount(edge.count) + "\\n" + formatProbability(edge.probability);
		lines.push("\t" + JSON.stringify(edge.from) + " -> " + JSON.stringify(edge.to) + " [label=" + JSON.stringify(label) + ", penwidth=" + (1 + edge.probability * 4).toFixed(2) + "];");
	}
	lines.push("}");
	lines.push("");
	return lines.join("\n");
}

function main() {
	let args;
	try {
		args = parseArgs(process.argv);
	} catch (error) {
		console.error(error.message);
		usage();
		process.exit(1);
	}

	const profile = loadProfile(args.input);
	const graph = buildGraph(profile);
	const clustering = buildGreedyClusters(graph);
	const report = buildReport(graph, args.topN, clustering);

	if (args.reportPath) {
		const resolvedReport = path.resolve(process.cwd(), args.reportPath);
		fs.mkdirSync(path.dirname(resolvedReport), { recursive: true });
		fs.writeFileSync(resolvedReport, report + "\n", "utf8");
	} else {
		process.stdout.write(report + "\n");
	}

	if (args.dotPath) {
		const edges = collectTopEdges(graph);
		const resolvedDot = path.resolve(process.cwd(), args.dotPath);
		fs.mkdirSync(path.dirname(resolvedDot), { recursive: true });
		fs.writeFileSync(resolvedDot, buildDot(graph, edges, args.topN) + "\n", "utf8");
	}

	if (args.orderPath) {
		const resolvedOrder = path.resolve(process.cwd(), args.orderPath);
		fs.mkdirSync(path.dirname(resolvedOrder), { recursive: true });
		fs.writeFileSync(resolvedOrder, clustering.order.join("\n") + "\n", "utf8");
	}
}

main();

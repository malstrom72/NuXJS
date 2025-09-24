#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

function usage() {
console.log("Usage: analyze_opcode_layout_results [--output file] result.json [...]");
console.log("");
console.log("Parses opcode layout benchmark experiments, computes summary statistics,");
console.log("and compares baseline against reordered candidates when possible.");
}

function parseArgs(argv) {
let outputPath = null;
const inputs = [];
for (let i = 0; i < argv.length; ++i) {
const arg = argv[i];
if (arg === "--output") {
if (i + 1 >= argv.length) {
fail("--output requires a value.");
}
outputPath = path.resolve(argv[++i]);
} else if (arg.startsWith("--output=")) {
outputPath = path.resolve(arg.substring("--output=".length));
} else if (arg === "--help" || arg === "-h") {
usage();
process.exit(0);
} else if (arg.startsWith("-")) {
fail(`Unknown option: ${arg}`);
} else {
inputs.push(path.resolve(arg));
}
}
if (inputs.length === 0) {
fail("Provide at least one results JSON file.");
}
return {outputPath, inputs};
}

function fail(message) {
console.error(message);
process.exit(1);
}

function readJson(file) {
const data = fs.readFileSync(file, "utf8");
return JSON.parse(data);
}

function collectRuns(candidate) {
const runs = [];
const failures = [];
for (const iteration of candidate.iterations) {
if (iteration.status !== 0) {
failures.push({
iteration: iteration.iteration,
status: iteration.status,
signal: iteration.signal,
durationMs: iteration.durationMs,
stdout: iteration.stdout,
stderr: iteration.stderr,
});
continue;
}
const parsed = parseRunsFromStdout(iteration.stdout);
runs.push(...parsed);
}
return {runs, failures};
}

function parseRunsFromStdout(stdout) {
const result = [];
const lines = stdout.split(/\r?\n/);
for (const rawLine of lines) {
const line = rawLine.trim();
if (line.length === 0) {
continue;
}
if (line.startsWith("median")) {
continue;
}
if (/^[0-9]+\.[0-9]+s$/.test(line)) {
result.push(Number.parseFloat(line.substring(0, line.length - 1)));
}
}
return result;
}

function describeSamples(samples) {
if (samples.length === 0) {
return {
size: 0,
mean: NaN,
median: NaN,
variance: NaN,
stddev: NaN,
min: NaN,
max: NaN,
};
}
const size = samples.length;
let sum = 0;
let min = samples[0];
let max = samples[0];
for (const value of samples) {
sum += value;
if (value < min) {
min = value;
}
if (value > max) {
max = value;
}
}
const mean = sum / size;
let sumSq = 0;
for (const value of samples) {
const delta = value - mean;
sumSq += delta * delta;
}
const variance = size > 1 ? sumSq / (size - 1) : 0;
const stddev = Math.sqrt(variance);
const sorted = samples.slice().sort((a, b) => a - b);
let median;
if (size % 2 === 0) {
const mid = size / 2;
median = (sorted[mid - 1] + sorted[mid]) / 2;
} else {
median = sorted[(size - 1) / 2];
}
return {size, mean, median, variance, stddev, min, max};
}

function welchTTest(sampleA, sampleB) {
if (sampleA.variance === 0 && sampleB.variance === 0) {
return {
t: 0,
df: Infinity,
p: 1,
};
}
const n1 = sampleA.size;
const n2 = sampleB.size;
if (n1 < 2 || n2 < 2) {
return null;
}
const v1 = sampleA.variance / n1;
const v2 = sampleB.variance / n2;
const diff = sampleA.mean - sampleB.mean;
const denom = Math.sqrt(v1 + v2);
const t = diff / denom;
const numerator = (v1 + v2) * (v1 + v2);
const denominator = ((v1 * v1) / (n1 - 1)) + ((v2 * v2) / (n2 - 1));
const df = numerator / denominator;
const p = 2 * (1 - studentsTCdf(Math.abs(t), df));
return {t, df, p, diff};
}

function studentsTCdf(t, df) {
if (!Number.isFinite(t) || !Number.isFinite(df) || df <= 0) {
return NaN;
}
const x = df / (df + t * t);
const ib = regularizedIncompleteBeta(x, df / 2, 0.5);
const half = 0.5 * ib;
return t >= 0 ? 1 - half : half;
}

function regularizedIncompleteBeta(x, a, b) {
if (x <= 0) {
return 0;
}
if (x >= 1) {
return 1;
}
const bt = Math.exp(gammaln(a + b) - gammaln(a) - gammaln(b) + a * Math.log(x) + b * Math.log(1 - x));
let result;
if (x < (a + 1) / (a + b + 2)) {
result = bt * betacf(x, a, b) / a;
} else {
result = 1 - bt * betacf(1 - x, b, a) / b;
}
return Math.max(0, Math.min(1, result));
}

function betacf(x, a, b) {
const MAX_ITER = 200;
const EPS = 3e-7;
let qab = a + b;
let qap = a + 1;
let qam = a - 1;
let c = 1;
let d = 1 - qab * x / qap;
if (Math.abs(d) < 1e-30) {
d = 1e-30;
}
d = 1 / d;
let h = d;
for (let m = 1; m <= MAX_ITER; ++m) {
const m2 = 2 * m;
let aa = m * (b - m) * x / ((qam + m2) * (a + m2));
d = 1 + aa * d;
if (Math.abs(d) < 1e-30) {
d = 1e-30;
}
c = 1 + aa / c;
if (Math.abs(c) < 1e-30) {
c = 1e-30;
}
d = 1 / d;
h *= d * c;
aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));
d = 1 + aa * d;
if (Math.abs(d) < 1e-30) {
d = 1e-30;
}
c = 1 + aa / c;
if (Math.abs(c) < 1e-30) {
c = 1e-30;
}
d = 1 / d;
const delta = d * c;
h *= delta;
if (Math.abs(delta - 1) < EPS) {
break;
}
}
return h;
}

function gammaln(z) {
const p = [
0.99999999999980993,
676.5203681218851,
-1259.1392167224028,
771.32342877765313,
-176.61502916214059,
12.507343278686905,
-0.13857109526572012,
9.9843695780195716e-6,
1.5056327351493116e-7,
];
if (z < 0.5) {
return Math.log(Math.PI) - Math.log(Math.sin(Math.PI * z)) - gammaln(1 - z);
}
z -= 1;
let x = p[0];
for (let i = 1; i < p.length; ++i) {
x += p[i] / (z + i);
}
const g = 7;
const t = z + g + 0.5;
return 0.9189385332046727 + (z + 0.5) * Math.log(t) - t + Math.log(x);
}

function formatNumber(value, digits = 4) {
if (!Number.isFinite(value)) {
return "n/a";
}
return value.toFixed(digits);
}

function summarizeFile(file, data) {
const lines = [];
lines.push(`### ${path.basename(file)}`);
lines.push("");
lines.push("| Candidate | Runs | Mean (s) | Median (s) | StdDev (s) | Min (s) | Max (s) | Notes |");
lines.push("| --- | ---: | ---: | ---: | ---: | ---: | ---: | :--- |");
const statsByLabel = new Map();
for (const candidate of data.candidates) {
const {runs, failures} = collectRuns(candidate);
const stats = describeSamples(runs);
statsByLabel.set(candidate.label, {stats, failures, runs});
const notes = [];
if (failures.length !== 0) {
notes.push(`${failures.length} failure(s)`);
}
lines.push(`| ${candidate.label} | ${stats.size} | ${formatNumber(stats.mean)} | ${formatNumber(stats.median)} | ${formatNumber(stats.stddev)} | ${formatNumber(stats.min)} | ${formatNumber(stats.max)} | ${notes.join("; ")} |`);
}
lines.push("");
const baseline = statsByLabel.get("baseline");
const anneal = statsByLabel.get("anneal");
if (baseline && anneal && baseline.stats.size > 1 && anneal.stats.size > 1 && anneal.failures.length === 0) {
const comparison = welchTTest(baseline.stats, anneal.stats);
if (comparison) {
const delta = anneal.stats.mean - baseline.stats.mean;
const percent = (delta / baseline.stats.mean) * 100;
const significance = comparison.p < 0.05 ? "significant" : "not significant";
lines.push(`Welch's t-test (anneal vs baseline): t = ${formatNumber(comparison.t, 3)}, dof = ${formatNumber(comparison.df, 1)}, p = ${formatNumber(comparison.p, 3)} (${significance}).`);
lines.push(`Mean delta: ${formatNumber(delta, 4)}s (${formatNumber(percent, 2)}%).`);
lines.push("");
}
} else if (anneal && anneal.failures.length !== 0) {
lines.push("Anneal candidate encountered failures; statistical comparison skipped.");
lines.push("");
}
return lines.join("\n");
}


function main() {
const options = parseArgs(process.argv.slice(2));
const sections = [];
for (const input of options.inputs) {
const data = readJson(input);
sections.push(summarizeFile(input, data));
}
const report = sections.join("\n\n");
if (options.outputPath) {
fs.mkdirSync(path.dirname(options.outputPath), {recursive: true});
fs.writeFileSync(options.outputPath, report + "\n");
console.log(`Wrote analysis to ${options.outputPath}`);
} else {
console.log(report);
}
}

if (require.main === module) {
main();
}

module.exports = {
studentsTCdf,
};

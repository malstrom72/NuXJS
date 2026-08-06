"use strict";

const fs = require("fs");
const path = require("path");
const http = require("http");
const url = require("url");
const child_process = require("child_process");
const readline = require("readline");

const TEST_PATH = "./externals/test262-master/";
const TEST_TAR = "./externals/test262-master.tar.gz";

// Simple arg helpers to support both "--name value" and "--name=value"
function findArg(name) {
	const eq = "--" + name + "=";
	for (let i = 0; i < process.argv.length; i++) {
		const a = process.argv[i];
		if (a === "--" + name) return { type: "separate", index: i };
		if (a.indexOf(eq) === 0) return { type: "equals", value: a.substr(eq.length) };
	}
	return null;
}
function getBool(name) {
	const hit = findArg(name);
	if (!hit) return false;
	if (hit.type === "equals") {
		const v = hit.value.trim().toLowerCase();
		return v === "1" || v === "true" || v === "yes";
	}
	return true;
}
function getInt(name, def) {
	const hit = findArg(name);
	if (!hit) return def;
	const raw = hit.type === "separate" ? process.argv[hit.index + 1] : hit.value;
	const n = parseInt(raw, 10);
	return isFinite(n) ? n : def;
}
function getString(name, def) {
	const hit = findArg(name);
	if (!hit) return def;
	return (hit.type === "separate" ? process.argv[hit.index + 1] : hit.value) || def;
}

// The dashboard scores the target edition, so picking the es3 binary would be silently wrong. --engine overrides.
function resolveEngine() {
	const override = getString("engine", "");
	if (override) return override;
	const ext = process.platform === "win32" ? ".exe" : "";
	const names = ["NuXJS_es5_release_native", "NuXJS_es5_beta_native", "NuXJS_es5_release_x64",
			"NuXJS_es5_debug_x64", "NuXJS_beta_native", "NuXJS_release_native"];
	for (let i = 0; i < names.length; i++) {
		const p = path.join(".", "output", names[i] + ext);
		if (fs.existsSync(p)) return p;
	}
	return path.join(".", "output", "NuXJS" + ext);	// cmd resolves the .exe on win32
}
const ENGINE = resolveEngine();

// test262.py runs each test in both modes unless restricted. Strict mode is an ES5.1 feature and 482 tests are
// onlyStrict, so --non_strict_only silently drops them: --include-strict is what makes those count.
const TEST_ARGS_BASE = ["-u", "./externals/test262-master/tools/packaging/test262.py"]
	.concat(getBool("include-strict") ? [] : ["--non_strict_only"])
	.concat([
		"--tests=" + TEST_PATH,
		"--command=" + (process.platform === "win32" ? '"' + path.resolve(ENGINE) + '"' : ENGINE) + " -s",
	]);

// Resolve a Python 2 interpreter robustly:
// 1) Respect NUXJS_PYTHON2 if provided
// 2) Prefer the repo's portable env created by tools/setupPython2.*
// 3) Fall back to "python2" on PATH
function resolvePython2() {
	const envOverride = process.env.NUXJS_PYTHON2 && process.env.NUXJS_PYTHON2.trim();
	if (envOverride) return envOverride;

	if (process.platform === "win32") {
		const exe = path.join(__dirname, "..", "output", "python2", "env", "python.exe");
		if (fs.existsSync(exe)) return exe;
	} else {
		const shim = path.join(process.env.HOME || "", ".local", "bin", "python2");
		if (shim && fs.existsSync(shim)) return shim;
	}

	return "python2";
}
const PY2 = resolvePython2();

if (!fs.existsSync(TEST_PATH)) {
	console.log("Extracting Test262 suite to externals/...");
	if (!fs.existsSync("./externals")) fs.mkdirSync("./externals", { recursive: true });
	child_process.execFileSync("tar", ["-xzf", TEST_TAR, "-C", "./externals"]);
}
function interpretResult(text) {
	text = text
		.replace(/\x1B\[[0-9;]*m/g, "")
		.trim()
		.toLowerCase();
	text = text.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
	if (text.indexOf("pass") === 0) return true;
	if (text.indexOf("fail") === 0 && text.indexOf("expected") !== -1) return true;
	if (text.indexOf("was expected to fail") !== -1) return false;
	if (text.indexOf("fail") === 0) return false;
	throw 'Unknown test result: "' + text + '"';
}

/*
	The edition a test targets is not a human judgement, it is stated in the test's own frontmatter: test262 tags
	each one with the clause number of the edition it was written against, so `es5id` is an ES5.1 test while
	`es6id` and the unversioned `esid` are newer. Deriving the out-of-scope bucket from that keeps testdash.json
	down to the calls a human actually made, and retargeting to a later edition is then this one object.
*/
const TARGET = { id: "es5id", category: "not_es51", label: "ES >5.1" };
const EDITION_IDS = ["es5id", "es6id", "esid"];

const CATEGORY_LABELS = {
	bad_test: "BAD TEST",
	by_design: "BY DESIGN",
	tbd: "TBD",
	todo: "TODO",
};
CATEGORY_LABELS[TARGET.category] = TARGET.label;
const CATEGORIES_TO_IGNORE = { bad_test: true, by_design: true, tbd: true };
CATEGORIES_TO_IGNORE[TARGET.category] = true;

const editions = {};
function testEdition(testName) {
	if (editions[testName] === undefined) {
		var head = "";
		try {
			head = fs.readFileSync(path.join(TEST_PATH, "test", testName + ".js"), "utf8").substr(0, 6000);
		} catch (e) {
			// Not in this snapshot. Left unclassified so a stale entry surfaces instead of being quietly ignored.
		}
		const block = /\/\*---([\s\S]*?)---\*\//.exec(head);	// the ids may be indented inside the frontmatter
		editions[testName] = EDITION_IDS.filter(function (id) {
			return new RegExp("^\\s*" + id + "\\s*:", "m").test(block ? block[1] : head);
		})[0] || "";
	}
	return editions[testName];
}
function categoryOf(testName) {
	const stored = config[testName] && config[testName].category;
	if (stored) return stored;
	const edition = testEdition(testName);
	return edition !== "" && edition !== TARGET.id ? TARGET.category : "";
}

var tests = {};
var config = {};
function saveConfig() {
	fs.writeFileSync("./tools/testdash.json", JSON.stringify(config, null, "\t"));
}
function loadConfig() {
	config = JSON.parse(fs.readFileSync("./tools/testdash.json"));
}
function extend(target, obj) {
	for (var p in obj) if (obj.hasOwnProperty(p)) target[p] = obj[p];
	return target;
}

var runningTest = false;
var currentTest = undefined;
function listSubdirs(relRoot) {
	const abs = path.join(TEST_PATH, "test", relRoot);
	try {
		const entries = fs.readdirSync(abs, { withFileTypes: true });
		return entries
			.filter((e) => e.isDirectory())
			.map((e) => path.join(relRoot, e.name));
	} catch (e) {
		// Fallback if the path doesn't exist on a given snapshot
		return [];
	}
}

function buildWorkList(limit) {
	// Keep the small, fast subset for quick limit runs
	if (limit) return [path.join("language", "arguments")];
	/*
		Fan out across first-level subdirectories for better parallelism. test262.py matches each of these as a
		substring of a test's path rather than as an anchored prefix, so "built-ins/Date" also picks up
		"annexB/built-ins/Date". annexB is still listed in its own right: it has folders that test/built-ins does
		not (escape, unescape), and those are reachable by no pattern at all otherwise, so their tests silently
		never run and never appear as passed, failed or ignored. The resulting overlap costs a few duplicate
		executions and nothing else, the totals being keyed by test name. Two roots stay out deliberately:
		harness/ holds include files rather than tests, and intl402/ is ECMA-402, a different specification.
	*/
	let work = [];
	["language", "built-ins", "annexB"].forEach((root) => {
		const subs = listSubdirs(root);
		if (subs.length) work = work.concat(subs);
		else work.push(root); // fallback to root if no subdirs found
	});
	return work;
}

function runTests(callback, limit, jobs) {
	runningTest = true;
	currentTest = undefined;
	console.log("Running tests");
	var count = 0;
	const dirArgs = buildWorkList(limit);
	jobs = Math.max(1, jobs | 0);

	const chunks = [];
	for (let i = 0; i < jobs; i++) chunks[i] = [];
	for (let i = 0; i < dirArgs.length; i++) chunks[i % jobs].push(dirArgs[i]);

	const children = [];
	const captureMode = [];
	const currentTests = [];
	let remaining = chunks.filter((c) => c.length > 0).length;
	console.log("starting " + remaining + " jobs");

	function onClose() {
		if (--remaining === 0) {
			console.log("Completed");
			runningTest = false;
			if (callback) callback();
		}
	}

	chunks.forEach((chunk, idx) => {
		if (chunk.length === 0) return;
		var args = TEST_ARGS_BASE.concat(chunk);
		var child = child_process.spawn(PY2, args);
		children.push(child);
		captureMode[idx] = false;
		currentTests[idx] = undefined;
		child.stderr && child.stderr.on("data", (d) => {
			const s = d.toString();
			if (s.trim()) console.error("[worker " + idx + "] STDERR: " + s.trim());
		});
		child.on("error", (e) => {
			console.error("Child process error [" + idx + "]: " + e.message);
		});
		readline
			.createInterface({
				input: child.stdout,
			})
			.on("line", (line) => {
				// Some chunks may legitimately contain no tests; ignore such notices early
				if (/^\s*(?:Error:\s+)?No tests to run\b/i.test(line)) {
					console.warn("[worker " + idx + "] " + line.trim());
					return;
				}
				if (captureMode[idx]) {
					if (line.substr(-3) === "===") {
						line = line.slice(0, -3);
						captureMode[idx] = false;
					}
					currentTests[idx].output += line + "\n";
				} else {
					var m = line.match(/(=== )?(\S+) (.+?)( ===)?$/);
					if (m) {
						var testName = m[2];
						testName = testName.replace(/\\/g, "/");
						var passed = interpretResult(m[3]);
						tests[testName] = extend({ name: testName, passed: passed, output: "" }, config[testName]);
						tests[testName].category = categoryOf(testName);
						currentTest = currentTests[idx] = tests[testName];
						captureMode[idx] = m[4] === " ===";
						count++;
						if (count % 100 === 0) console.log("... " + count + " tests run");
						if (limit && count >= limit) children.forEach((c) => c.kill("SIGKILL"));
					} else if (line) {
						console.warn("Unknown output: " + line);
					}
				}
			})
			.on("close", onClose);
	});
}

var server = http.createServer(function (req, res) {
	try {
		var u = url.parse(req.url, true);
		if (u.pathname === "/") u.pathname = "/tools/testdash.html";
		if (u.pathname.substr(0, 8) === "/source/") u.pathname = "/" + TEST_PATH + "test/" + u.pathname.substr(8) + ".js";

		if (u.pathname.substr(0, 5) === "/api/") {
			var method = u.pathname.substr(5);
			var output = undefined;

			if (method === "status") {
				if (runningTest) output = { mode: "running", currentTest: currentTest };
				else output = { mode: "report", tests: tests };
			} else if (method === "runTests") {
				if (!runningTest) runTests(undefined, maxTests, jobs);
				output = { ok: true };
			} else if (method === "setCategory") {
				var testName = u.query.test;
				var category = u.query.category;
				if (tests[testName]) {
					config[testName] = config[testName] || {};
					config[testName].category = category;
					tests[testName].category = category;
					saveConfig();
				}
				output = tests[testName];
			}

			if (output !== undefined) res.write(JSON.stringify(output));
			else res.writeHead(400, "Bad Request");
			res.end();
		} else if (u.pathname != "/") {
			var p = u.pathname.replace(/\.\./g, ""); // remove .. from path for security
			if (fs.existsSync("." + p)) {
				res.writeHead(200, "OK", { "Content-Type": "text/html" });
				fs.createReadStream("." + p, { flags: "r", autoClose: true }).pipe(res);
			} else {
				res.writeHead(404, "Not Found", { "Content-Type": "text/plain" });
				res.write("404 Not Found");
				res.end();
			}
		} else res.end();
	} catch (e) {
		console.error("HTTP server error: " + e);
	}
});

loadConfig();

var cliMode = getBool("cli");
var maxTests = getInt("limit", undefined);
var jobs = getInt("jobs", 1);
var includeIgnored = getBool("include-ignored");
var resetPassed = getBool("reset-passed"); // implies include-ignored
if (resetPassed) includeIgnored = true;

if (cliMode) {
	runTests(
		() => {
			var totals = { total: 0, passed: 0, failed: 0, ignored: 0 };
			var ignored = {};
			for (var testName in tests) {
				if (tests.hasOwnProperty(testName)) {
					var t = tests[testName];
					totals.total++;
					if (!includeIgnored && CATEGORIES_TO_IGNORE[t.category]) {
						totals.ignored++;
						ignored[t.category] = (ignored[t.category] || 0) + 1;
					} else if (t.passed) {
						totals.passed++;
					} else {
						totals.failed++;
						console.log(testName);
						console.log("source");
						console.log("--- output ---");
						process.stdout.write(t.output);
						if (t.output.substr(-1) !== "\n") console.log();
						console.log();
					}
				}
			}

			// Optionally clear categories for passing tests (no changes for failures)
			if (resetPassed) {
				var changed = 0;
				for (var testName in tests) {
					if (tests.hasOwnProperty(testName)) {
						var t = tests[testName];
						if (t.passed && config[testName] && config[testName].category) {
							delete config[testName].category;
							if (Object.keys(config[testName]).length === 0) delete config[testName];
							changed++;
						}
					}
				}
				if (changed) {
					saveConfig();
					console.log("Reset categories on " + changed + " passing test(s).");
				} else console.log("No categories to reset.");
			}

			console.log("Total: " + totals.total);
			console.log("  Passed: " + totals.passed);
			console.log("  Failed: " + totals.failed);
			console.log("  Ignored: " + totals.ignored);
			for (var c in ignored) {
				console.log("	 " + (CATEGORY_LABELS[c] || c) + ": " + ignored[c]);
			}
			process.exit(totals.failed);
		},
		maxTests,
		jobs,
	);
} else {
	server.listen(12345, () => {
		const address = server.address();
		const urlToOpen = "http://localhost:" + address.port;
		console.log("opened HTTP server on " + urlToOpen);

		let cmd, args;
		if (process.platform === "win32") {
			cmd = "cmd";
			args = ["/c", "start", "", urlToOpen];
		} else if (process.platform === "darwin") {
			cmd = "open";
			args = [urlToOpen];
		} else {
			cmd = "xdg-open";
			args = [urlToOpen];
		}

		try {
			const opener = child_process.spawn(cmd, args, { detached: true, stdio: "ignore" });
			opener.on("error", (e) => console.warn("Failed to open browser: " + e.message));
			opener.unref();
		} catch (e) {
			console.warn("Failed to open browser: " + e.message);
		}
	});
	runTests(undefined, maxTests, jobs);
}

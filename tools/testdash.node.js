"use strict";

const fs = require("fs");
const path = require("path");
const http = require("http");
const url = require("url");
const child_process = require("child_process");
const readline = require("readline");

const TEST_PATH = "./externals/test262-master/";
const TEST_TAR = "./externals/test262-master.tar.gz";

// Resolve the engine binary across platforms/build variants
function resolveEngine() {
	// Prefer platform-specific names
	if (process.platform === "win32") {
		if (fs.existsSync(path.join(".", "output", "NuXJS_beta_x64.exe"))) return path.join(".", "output", "NuXJS_beta_x64.exe");
		if (fs.existsSync(path.join(".", "output", "NuXJS.exe"))) return path.join(".", "output", "NuXJS.exe");
		// fallback to non-.exe name (cmd will resolve .exe)
		return path.join(".", "output", "NuXJS");
	}
	if (fs.existsSync("./output/NuXJS_beta_native")) return "./output/NuXJS_beta_native";
	if (fs.existsSync("./output/NuXJS_release_native")) return "./output/NuXJS_release_native";
	return "./output/NuXJS";
}
const ENGINE = resolveEngine();

const TEST_ARGS_BASE = [
	"-u",
	"./externals/test262-master/tools/packaging/test262.py",
	"--non_strict_only",
	"--tests=" + TEST_PATH,
	"--command=" + (process.platform === "win32" ? '"' + path.resolve(ENGINE) + '"' : ENGINE) + " -s",
];

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

const CATEGORY_LABELS = {
	bad_test: "BAD TEST",
	by_design: "BY DESIGN",
	not_es3: "ES >3",
	tbd: "TBD",
	todo: "TODO",
};
const CATEGORIES_TO_IGNORE = { bad_test: true, by_design: true, not_es3: true, tbd: true };

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
function runTests(callback, limit) {
	runningTest = true;
	currentTest = undefined;
	console.log("Running tests");
	var captureMode = false;
	var count = 0;
	const dirs = limit ? [path.join("language", "arguments")] : ["language", "built-ins"];

	function runDir(index) {
		if (index >= dirs.length) {
			console.log("Completed");
			runningTest = false;
			if (callback) callback();
			return;
		}

		captureMode = false;
		var args = TEST_ARGS_BASE.concat(dirs[index]);
		var child = child_process.spawn(PY2, args);
		readline
			.createInterface({ input: child.stdout })
			.on("line", (line) => {
				if (captureMode) {
					if (line.substr(-3) === "===") {
						line = line.slice(0, -3);
						captureMode = false;
					}
					currentTest.output += line + "\n";
				} else {
					var m = line.match(/(=== )?(\S+) (.+?)( ===)?$/);
					if (m) {
						var testName = m[2];
						testName = testName.replace(/\\/g, "/");
						var passed = interpretResult(m[3]);
						tests[testName] = extend({ name: testName, passed: passed, output: "" }, config[testName]);
						currentTest = tests[testName];
						captureMode = m[4] === " ===";
						count++;
						if (limit && count >= limit) child.kill("SIGKILL");
					} else if (line) {
						if (/^Error:\s+No tests to run/i.test(line)) {
							console.error(line);
							return;
						}
						console.warn("Unknown output: " + line);
					}
				}
			})
			.on("close", () => runDir(index + 1));
	}

	runDir(0);
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
				if (!runningTest) runTests(undefined, maxTests);
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

var cliMode = process.argv.indexOf("--cli") !== -1;
var limitIndex = process.argv.indexOf("--limit");
var maxTests = limitIndex !== -1 ? parseInt(process.argv[limitIndex + 1]) : undefined;
var includeIgnored = process.argv.indexOf("--include-ignored") !== -1;
var resetPassed = process.argv.indexOf("--reset-passed") !== -1; // implies include-ignored
if (resetPassed) includeIgnored = true;

if (cliMode) {
	runTests(() => {
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
					console.log("FAIL " + testName);
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
	}, maxTests);
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
	runTests(undefined, maxTests);
}

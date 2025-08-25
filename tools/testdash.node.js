"use strict";

const fs = require("fs");
const http = require("http");
const url = require("url");
const child_process = require("child_process");
const readline = require("readline");
const path = require("path");

const TEST_PATH = "./test262-master/";
const TEST_TAR = "./externals/test262-master.tar.gz";

function findEngine() {
        const candidates = [
                "./output/NuXJS_beta_native",
                "./output/NuXJS_release_native",
                "./output/NuXJS"
        ];
        for (const p of candidates) {
                try {
                        fs.accessSync(p, fs.constants.X_OK);
                        return path.resolve(p);
                } catch (_) {}
        }
        console.error("NuXJS binary not found. Build the project before running tests.");
        process.exit(1);
}

const ENGINE = findEngine();

function ensureTest262() {
	if (!fs.existsSync(TEST_PATH) || !fs.existsSync(path.join(TEST_PATH, "package.json"))) {
		if (!fs.existsSync(TEST_TAR)) {
			const fetchScript = process.platform === "win32" ? "tools\\fetchTest262.cmd" : "tools/fetchTest262.sh";
			const runner = process.platform === "win32" ? "cmd" : "bash";
			console.log("Downloading Test262 suite...");
			child_process.execFileSync(runner, [fetchScript], { stdio: "inherit" });
		}
		console.log("Extracting Test262 suite...");
		child_process.execFileSync("tar", ["-xzf", TEST_TAR]);
	}
}

ensureTest262();

const CATEGORY_LABELS = {
	bad_test: "BAD TEST",
	by_design: "BY DESIGN",
	not_es3: "ES >3",
	tbd: "TBD",
	todo: "TODO"
};
const CATEGORIES_TO_IGNORE = { bad_test:true, by_design:true, not_es3:true, tbd:true };
const NON_ES3_DIRS = new Set(["annexB", "intl402"]);

var tests = {};
var config = {};
function saveConfig() { fs.writeFileSync("./tools/testdash.json", JSON.stringify(config, null, '\t')); };
function loadConfig() { config = JSON.parse(fs.readFileSync("./tools/testdash.json")); };
function extend(target, obj) { for (var p in obj) if (obj.hasOwnProperty(p)) target[p] = obj[p]; return target; };

var runningTest = false;
var currentTest = undefined;
function runTests(callback, limit) {
	runningTest = true;
	currentTest = undefined;
	tests = {};
	console.log("Running tests");
	if (!fs.existsSync(TEST_PATH + "node_modules")) {
	       child_process.execFileSync("npm", ["--prefix", TEST_PATH, "install"], { stdio:"inherit" });
	}
        var harness = "node_modules/test262-harness/bin/run.js";
        var hostType = "jsshell";
        var args = ["--reporter=json", "--reporter-keys=file,result", "--hostType=" + hostType, "--hostPath=" + ENGINE];

if (limit) {
var list = [];
(function gather(dir) {
var entries = fs.readdirSync(dir, { withFileTypes:true });
for (var entry of entries) {
var full = path.join(dir, entry.name);
if (entry.isDirectory()) gather(full);
else if (entry.name.endsWith(".js")) {
var text = fs.readFileSync(full, "utf8");
if (/\bfeatures\b/.test(text) || /\bflags\b/.test(text)) continue;
list.push(path.relative(TEST_PATH, full));
}
}
})(path.join(TEST_PATH, "test", "language"));
list.sort();
if (list.length > limit) list = list.slice(0, limit);
args = args.concat(list);
} else {
args.push("test/language/**/*.js");
}

	var child = child_process.spawn("node", [harness].concat(args), { cwd: TEST_PATH });
	var output = "";
	child.stdout.setEncoding("utf8");
	child.stdout.on("data", (chunk) => { output += chunk; });
	child.stdout.on("end", () => {
		try {
		       output.split(/\r?\n/).forEach((line) => {
			       line = line.trim();
			       if (!line || line === "[" || line === "]") return;
			       if (line[0] === ",") line = line.slice(1);
			       if (line.endsWith(",")) line = line.slice(0, -1);
			       var m = JSON.parse(line);
                               var testName = m.file;
                               var configKey = testName.startsWith("test/") ? testName.slice(5) : testName;
                               configKey = configKey.replace(/\.js$/, "");
                               var passed = m.result.pass === true;
                               var defaultCategory;
                               for (var dir of NON_ES3_DIRS) {
                                       if (testName.startsWith("test/" + dir + "/")) { defaultCategory = "not_es3"; break; }
                               }
                               tests[testName] = extend({ name:testName, passed:passed, output:"", category:defaultCategory }, config[configKey]);
                               currentTest = tests[testName];
                       });
		} catch (e) {
			console.error("Parse error: " + e);
		}
	});
	child.stderr.setEncoding("utf8");
	child.stderr.on("data", (chunk) => { console.error(chunk); });
	child.on("close", () => {
		console.log("Completed");
		runningTest = false;
		if (callback) callback();
	});
};

var server = http.createServer( function(req, res) {
	try {
		var u = url.parse(req.url, true);
		if (u.pathname === "/") u.pathname = "/tools/testdash.html";
		if (u.pathname.substr(0,8) === "/source/") u.pathname = "/" + TEST_PATH + "test/" + u.pathname.substr(8) + ".js";

		if (u.pathname.substr(0,5) === "/api/") {
			var method = u.pathname.substr(5);
			var output = undefined;

			if (method === "status") {
				if (runningTest) output = { mode:"running", currentTest:currentTest };
				else output = { mode:"report", tests:tests };
			} else if (method === "runTests") {
				if (!runningTest) runTests(undefined, maxTests);
				output = { ok:true };
			} else if (method === "setCategory") {
				var testName = u.query.test;
				var category = u.query.category;
                               var configKey = testName && testName.startsWith("test/") ? testName.slice(5) : testName;
                               configKey = configKey && configKey.replace(/\.js$/, "");
                                if (tests[testName]) {
                                        config[configKey] = config[configKey] || {};
                                        config[configKey].category = category;
                                        tests[testName].category = category;
                                        saveConfig();
                                }
                                output = tests[testName];
                        }

			if (output !== undefined) res.write( JSON.stringify(output) );
			else res.writeHead(400, "Bad Request");
			res.end();
			
		} else if (u.pathname != "/") {
			var p = u.pathname.replace(/\.\./g, "");	// remove .. from path for security
			if (fs.existsSync("." + p)) {
				res.writeHead(200, "OK", { "Content-Type":"text/html" });
				fs.createReadStream("." + p, { flags:"r", autoClose:true }).pipe(res);
	} else {
				res.writeHead(404, "Not Found", { "Content-Type":"text/plain" });
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
var maxTests = (limitIndex !== -1) ? parseInt(process.argv[limitIndex + 1]) : undefined;

if (cliMode) {
	runTests(() => {
	       var totals = { total:0, passed:0, failed:0, ignored:0 };
	       var ignored = {};
	       for (var testName in tests) {
		       if (tests.hasOwnProperty(testName)) {
			       var t = tests[testName];
			       totals.total++;
			       if (CATEGORIES_TO_IGNORE[t.category]) {
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
	       console.log("Total: " + totals.total);
	       console.log("  Passed: " + totals.passed);
	       console.log("  Failed: " + totals.failed);
	       console.log("  Ignored: " + totals.ignored);
	       for (var c in ignored) {
		       console.log("    " + (CATEGORY_LABELS[c] || c) + ": " + ignored[c]);
	       }
	       process.exit(totals.failed);
	}, maxTests);
	} else {
	server.listen(12345, () => {
		var address = server.address();
		console.log("opened HTTP server on http://" + address.address + ":" + address.port);
		child_process.spawn("open", [ "http://localhost:" + address.port ]);
	});
	runTests(undefined, maxTests);
}

"use strict";

const fs = require("fs");
const http = require("http");
const url = require("url");
const child_process = require("child_process");
const readline = require("readline");
const path = require("path");

const TEST_PATH = "./test262-master/";
const TEST_TAR = "./externals/test262-master.tar.gz";
const ENGINE = (() => {
	const candidates = [
		"./output/NuXJS_beta_native",
		"./output/NuXJS_release_native",
		"./output/NuXJS",
		"./output/NuXJS.exe",
	];
	console.log("Engine path candidates:", candidates.join(", "));
	for (const c of candidates) {
		if (fs.existsSync(c)) {
			console.log("Found engine at", c);
			return path.resolve(c);
		} else {
			console.log("Engine not found:", c);
		}
	}
	console.log("No NuXJS binary found; falling back to Node");
	return "node";
})();
console.log("Selected engine:", ENGINE);

function ensureTest262() {
	if (!fs.existsSync(TEST_PATH) || !fs.existsSync(path.join(TEST_PATH, "package.json"))) {
		if (!fs.existsSync(TEST_TAR)) {
			const fetchScript = process.platform === "win32" ? "tools\\fetchTest262.cmd" : "tools/fetchTest262.sh";
			const runner = process.platform === "win32" ? "cmd" : "bash";
			const args = process.platform === "win32" ? ["/c", fetchScript] : [fetchScript];
			console.log("Downloading Test262 suite...");
			child_process.execFileSync(runner, args, { stdio: "inherit" });
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
	console.log("Running tests using", ENGINE);
	if (!fs.existsSync(TEST_PATH + "node_modules")) {
		const runner = process.platform === "win32" ? "cmd" : "npm";
		const args = process.platform === "win32" ? ["/c", "npm", "install"] : ["install"];
		child_process.execFileSync(runner, args, { cwd:TEST_PATH, stdio:"inherit" });
	}
	 var harness = "node_modules/test262-harness/bin/run.js";
	 var hostType = ENGINE === "node" ? "node" : "jsshell";
	 var args = ["--reporter=json", "--reporter-keys=file,result,stdout,stderr", "--hostType=" + hostType, "--hostPath=" + ENGINE];
	 console.log("Harness command:", "node", harness, args.join(" "));

	if (limit) {
	       var list = [];
		(function gather(dir) {
			var entries = fs.readdirSync(dir).sort();
			for (var i = 0; i < entries.length && list.length < limit; i++) {
			        var entry = entries[i];
			        if (NON_ES3_DIRS.has(entry)) continue;
			        var full = path.join(dir, entry);
			        var stat = fs.statSync(full);
			        if (stat.isDirectory()) gather(full);
			        else if (entry.endsWith(".js")) list.push(path.relative(TEST_PATH, full));
			}
		})(path.join(TEST_PATH, "test"));
		args = args.concat(list);
	} else {
		args.push("test/language/**/*.js");
	}

       var child = child_process.spawn("node", [harness].concat(args), { cwd: TEST_PATH });
       child.stdout.setEncoding("utf8");
       readline.createInterface({ input: child.stdout }).on("line", (line) => {
               line = line.trim();
               if (!line || line === "[" || line === "]") return;
               if (line[0] === ",") line = line.slice(1);
               if (line.endsWith(",")) line = line.slice(0, -1);
               try {
                       var m = JSON.parse(line);
                       var testName = m.file;
                       var configKey = testName.startsWith("test/") ? testName.slice(5) : testName;
                       configKey = configKey.replace(/\.js$/, "");
                       var passed = m.result.pass === true;
                       var defaultCategory;
                       for (var dir of NON_ES3_DIRS) {
                               if (testName.startsWith("test/" + dir + "/")) { defaultCategory = "not_es3"; break; }
                       }
			var stdout = (m.result.stdout || "").trim();
			var stderr = (m.result.stderr || "").trim();
			var error = m.result.error || {};
			var exitCode = m.result.exitCode;
			tests[testName] = extend({ name:testName, passed:passed, stdout:stdout, stderr:stderr, error:error, exitCode:exitCode, raw:m.result, category:defaultCategory }, config[configKey]);
			currentTest = tests[testName];
               } catch (e) {
                       console.error("Parse error: " + e + " in line: " + line);
               }
       });
       child.stderr.setEncoding("utf8");
       child.stderr.on("data", (chunk) => { console.error(chunk); });
       child.on("close", (code, signal) => {
               console.log("Completed with code", code, "signal", signal);
               runningTest = false;
               if (callback) callback();
       });
};

var server = http.createServer( function(req, res) {
	try {
		var u = url.parse(req.url, true);
		if (u.pathname === "/") u.pathname = "/tools/testdash.html";
		var isSource = false;
		if (u.pathname.substr(0,8) === "/source/") {
			var src = u.pathname.substr(8);
			if (!src.endsWith(".js")) src += ".js";
			if (!src.startsWith("test/")) src = "test/" + src;
			console.log("Source request: " + src);
			u.pathname = "/" + TEST_PATH + src;
			isSource = true;
		}


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
				res.writeHead(200, "OK", { "Content-Type": (isSource ? "text/plain" : "text/html") });
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
					if (t.error && (t.error.name || t.error.message)) {
						console.log("  error: " + (t.error.name || "") + (t.error.message ? ": " + t.error.message : ""));
}
					if (typeof t.exitCode === "number") {
						console.log("  exit code: " + t.exitCode);
}
					if (t.stdout) console.log("  stdout: " + t.stdout);
					if (t.stderr) console.log("  stderr: " + t.stderr);
					if (t.raw) console.log("  raw result: " + JSON.stringify(t.raw));
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
		var url = "http://localhost:" + address.port;
		console.log("opened HTTP server on http://" + address.address + ":" + address.port);

		var cmd;
		var args;
		if (process.platform === "win32") {
			cmd = "cmd";
			args = ["/c", "start", "", url];
		} else if (process.platform === "darwin") {
			cmd = "open";
			args = [url];
		} else {
			cmd = "xdg-open";
			args = [url];
		}
		child_process.spawn(cmd, args);
	});
	runTests(undefined, maxTests);
}

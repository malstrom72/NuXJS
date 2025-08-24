"use strict";

const fs = require("fs");
const http = require("http");
const url = require("url");
const child_process = require("child_process");
const readline = require("readline");

const TEST_PATH = "./test262-master/";
const TEST_COMMAND = 'python2 ./test262-master/tools/packaging/test262.py --non_strict_only --tests="' + TEST_PATH + '" --command="./output/NuXJS -s" language/';
const PASS_RESULTS = {
	"passed in non-strict mode":true,
	"failed in non-strict mode":false,
	"failed in non-strict mode as expected":true,
	"was expected to fail in non-strict mode, but didn't":false,
};

var tests = {};
var config = {};
function saveConfig() { fs.writeFileSync("./tools/testdash.json", JSON.stringify(config, null, '\t')); };
function loadConfig() { config = JSON.parse(fs.readFileSync("./tools/testdash.json")); };
function extend(target, obj) { for (var p in obj) if (obj.hasOwnProperty(p)) target[p] = obj[p]; return target; };

var runningTest = false;
var currentTest = undefined;
function runTests(callback) {
	runningTest = true;
	currentTest = undefined;
	console.log("Running tests");
	var captureMode = false;

	var child = child_process.spawn("sh", [ "-c", TEST_COMMAND ]);
	var rl = readline.createInterface({
		input: child.stdout
	}).on("line", (line) => {
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
				var testResult = m[3];
				if (PASS_RESULTS[testResult] === undefined) throw ('Unknown test result: "' + testResult + '"');

				tests[testName] = extend( { name:testName, passed:PASS_RESULTS[testResult], output: "" }, config[testName] );
				currentTest = tests[testName];
				captureMode = m[4] === " ===";

			} else if (line) console.warn("Unknown output: " + line);
		}
		// console.log("> ", line);

	}).on("close", () => {
		console.log("Completed");
		runningTest = false;
		if (callback) callback();
		// console.log(tests);
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
				if (!runningTest) runTests();
				output = { ok:true };
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

if (cliMode) {
	runTests(() => {
		var total = 0;
		var passed = 0;
		for (var testName in tests) {
			if (tests.hasOwnProperty(testName)) {
				var t = tests[testName];
				console.log((t.passed ? "PASS" : "FAIL") + " " + testName);
				if (t.passed) passed++;
				total++;
			}
		}
		console.log("Total: " + total + ", Passed: " + passed + ", Failed: " + (total - passed));
	});
} else {
	server.listen(12345, () => {
		var address = server.address();
		console.log("opened HTTP server on http://" + address.address + ":" + address.port);
		child_process.spawn("open", [ "http://localhost:" + address.port ]);
	});
	runTests();
}

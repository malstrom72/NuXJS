"use strict";

const fs = require("fs");
const http = require("http");
const url = require("url");
const child_process = require("child_process");
const readline = require("readline");
const path = require("path");

const TEST_PATH = "./test262-master/";
const TEST_TAR = "./externals/test262-master.tar.gz";
const ENGINE = fs.existsSync("./output/NuXJS_beta_native") ? path.resolve("./output/NuXJS_beta_native") :
fs.existsSync("./output/NuXJS_release_native") ? path.resolve("./output/NuXJS_release_native") :
fs.existsSync("./output/NuXJS") ? path.resolve("./output/NuXJS") :
"node";

if (!fs.existsSync(TEST_PATH)) {
	console.log("Extracting Test262 suite...");
	child_process.execFileSync("tar", [ "-xzf", TEST_TAR ]);
}

const CATEGORY_LABELS = {
        bad_test: "BAD TEST",
        by_design: "BY DESIGN",
        not_es3: "ES >3",
        tbd: "TBD",
        todo: "TODO"
};
const CATEGORIES_TO_IGNORE = { bad_test:true, by_design:true, not_es3:true, tbd:true };

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
        console.log("Running tests");
        var testTarget = limit ? "test/language/arguments-object/10.5-1-s.js" : "test/language";
        if (!fs.existsSync(TEST_PATH + "node_modules")) {
                child_process.execFileSync("npm", ["--prefix", TEST_PATH, "install"], { stdio:"inherit" });
        }
        var harness = "node_modules/test262-harness/bin/run.js";
        var args = ["--reporter=json", "--reporter-keys=file,result", "--hostType=node", "--hostPath=" + ENGINE, testTarget];
        var child = child_process.spawn("node", [harness].concat(args), { cwd: TEST_PATH });
        var output = "";
        child.stdout.setEncoding("utf8");
        child.stdout.on("data", (chunk) => { output += chunk; });
        child.stdout.on("end", () => {
                try {
                        var results = JSON.parse(output);
                        results.forEach((m) => {
                                var testName = m.file;
                                var passed = m.result.pass === true;
                                tests[testName] = extend({ name:testName, passed:passed, output:"" }, config[testName]);
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

/*
	systools.js

	A port of PikaScript's systools.pika (file / directory / system helpers) to NuXJS.

	It relies only on the host natives provided by the NuXJS command-line tool:
		read(path)            - read a file into a string          (PikaScript: load)
		write(path, content)  - write a string to a file           (PikaScript: save)
		system(command)       - run a shell command, return status (PikaScript: system)
		getenv(name)          - environment variable or undefined  (PikaScript: getenv)

	Load it from another script with load("systools.js") (the helpers become globals), then use e.g.
	makeDir(), dir(), pathExists(), copyFile(), pipe(), currentDir(), etc.

	NOTE: the UNIX branch is exercised by systoolsTests.js. The WINDOWS branch is a direct port of
	systools.pika and has NOT been executed on Windows; treat it as untested.
*/

// ---- platform-dependent globals (assigned in the platform block below) ----
var PLATFORM, DIR_SLASH, DIR_SLASHES, DEL_COMMAND, MOVE_COMMAND, COPY_COMMAND, MKDIR_COMMAND, RMDIR_COMMAND
		, WIPE_DIR_COMMAND, DEV_NULL, DIRECT_ALL_TO_NULL, TEMP_DIR;
var quotePath, quoteWildcardPath, toNativePath, fromNativePath, currentDir, renameFile, pathExists
		, fileSize, isFileNewer, sleep, concatFiles, dir, discoverStatOptions, DIR_ORDER_OPTIONS;

PLATFORM = (getenv("windir") !== undefined || getenv("SystemRoot") !== undefined) ? "WINDOWS" : "UNIX";

// ---- small utilities ----

function time() { return Math.floor(new Date().getTime() / 1000); }

function trim(s) {
	var ws = " \t\r\n\f\v";
	var b = 0, e = s.length;
	while (b < e && ws.indexOf(s.charAt(b)) >= 0) ++b;
	while (e > b && ws.indexOf(s.charAt(e - 1)) >= 0) --e;
	return s.substring(b, e);
}

// Index of the last character of s that is contained in the set `chars`, or -1 if none.
function rfindOfSet(s, chars) {
	for (var i = s.length - 1; i >= 0; --i) {
		if (chars.indexOf(s.charAt(i)) >= 0) return i;
	}
	return -1;
}

function tokenizeLines(s, action) {
	if (s.length === 0) return;
	var lines = s.split("\n");
	for (var i = 0; i < lines.length; ++i) {
		if (lines[i].length > 0) action(lines[i]);
	}
}

// ---- path helpers (read DIR_SLASH / DIR_SLASHES at call time, so they work on either platform) ----

function appendDirSlash(p) {
	var last = (p.length > 0 ? p.charAt(p.length - 1) : DIR_SLASH);
	return (DIR_SLASHES.indexOf(last) >= 0) ? p : p + DIR_SLASH;
}

function removeDirSlash(p) {
	return (p.length > 0 && DIR_SLASHES.indexOf(p.charAt(p.length - 1)) >= 0) ? p.substring(0, p.length - 1) : p;
}

function dirOfPath(p) { return p.substring(0, rfindOfSet(p, DIR_SLASHES) + 1); }

function filenameOfPath(p) { return p.substring(rfindOfSet(p, DIR_SLASHES) + 1); }

function basenameOfPath(p) {
	var fn = p.substring(rfindOfSet(p, DIR_SLASHES) + 1);
	var i = fn.lastIndexOf(".");
	return (i >= 0) ? fn.substring(0, i) : fn;
}

function extensionOfPath(p) {
	var ext = p.substring(rfindOfSet(p, DIR_SLASH + "."));
	return (ext.charAt(0) === ".") ? ext : "";
}

// Returns { dir: ..., name: ..., ext: ... } ("" where a component is absent).
function splitPath(p) {
	return { dir: dirOfPath(p), name: basenameOfPath(p), ext: extensionOfPath(p) };
}

// ---- platform-independent system helpers (built on the natives + the command constants) ----

function shell(command, throwOnError) {
	if (throwOnError === undefined) throwOnError = true;
	var rc = system("(" + command + ")");
	if (rc != 0) {
		if (PLATFORM === "UNIX") rc = Math.floor(rc / 256);
		if (throwOnError) throw "Error executing " + command + ": " + rc;
	}
	return rc;
}

function randomFilename() {
	var n = (Math.floor(Math.random() * 0x100000000) ^ time()) >>> 0;
	var s = n.toString(16).toUpperCase();
	while (s.length < 8) s = "0" + s;
	return s;
}

function makeTempDir() {
	for (var i = 0; i < 100; ++i) {
		var d = TEMP_DIR + "NuXTemp" + randomFilename() + "/";
		if (system(MKDIR_COMMAND + " " + quotePath(d) + " " + DIRECT_ALL_TO_NULL) === 0) return d;
	}
	throw "Could not create a temporary directory under " + TEMP_DIR;
}

// Runs a command, returns its (trimmed) stdout. Throws on a non-zero exit unless throwOnError is false.
function pipe(command, throwOnError) {
	if (throwOnError === undefined) throwOnError = true;
	var tempDir = makeTempDir();
	var r = system("(" + command + ") 1>" + quotePath(tempDir + "stdout") + " 2>" + quotePath(tempDir + "stderr"));
	var err = "";
	try { err = read(tempDir + "stderr"); } catch (x) { err = ""; }
	if (throwOnError && r != 0) {
		wipeTempDir(tempDir);
		var msg = "Error executing " + command + " (" + r + ")";
		if (err.length > 0) {
			err = err.replace(/[\t\r\n]/g, " ");
			if (err.length > 80) err = err.substring(0, 77) + "...";
			msg += ": " + err + " (" + r + ")";
		}
		throw msg;
	}
	var o = read(tempDir + "stdout");
	wipeTempDir(tempDir);
	return trim(o);
}

function eraseFile(path, throwOnError) {
	return shell(DEL_COMMAND + " " + quoteWildcardPath(path) + " " + DIRECT_ALL_TO_NULL
			, throwOnError === undefined ? true : throwOnError);
}

function moveFile(from, to, throwOnError) {
	return shell(MOVE_COMMAND + " " + quoteWildcardPath(from) + " " + quotePath(to) + " " + DIRECT_ALL_TO_NULL
			, throwOnError === undefined ? true : throwOnError);
}

function copyFile(from, to, throwOnError) {
	return shell(COPY_COMMAND + " " + quoteWildcardPath(from) + " " + quotePath(to) + " " + DIRECT_ALL_TO_NULL
			, throwOnError === undefined ? true : throwOnError);
}

function makeDir(path, throwOnError) {
	return shell(MKDIR_COMMAND + " " + quotePath(path) + " " + DIRECT_ALL_TO_NULL
			, throwOnError === undefined ? true : throwOnError);
}

function removeDir(path, throwOnError) {
	return shell(RMDIR_COMMAND + " " + quotePath(path) + " " + DIRECT_ALL_TO_NULL
			, throwOnError === undefined ? true : throwOnError);
}

function wipeTempDir(path) {
	if (path.substring(0, TEMP_DIR.length) !== TEMP_DIR) throw "Cannot wipe directories that are not temporary";
	return system(WIPE_DIR_COMMAND + " " + quotePath(path) + " " + DIRECT_ALL_TO_NULL);
}

// ---- platform-specific implementations ----

if (PLATFORM === "UNIX") {

	DIR_SLASH = "/";
	DIR_SLASHES = "/";
	DEL_COMMAND = "rm -f";
	MOVE_COMMAND = "mv";
	COPY_COMMAND = "cp -fp";
	MKDIR_COMMAND = "mkdir";
	RMDIR_COMMAND = "rmdir";
	WIPE_DIR_COMMAND = "rm -Rf";
	DEV_NULL = "/dev/null";
	DIRECT_ALL_TO_NULL = "1>/dev/null 2>&1";
	TEMP_DIR = appendDirSlash(getenv("TMPDIR") !== undefined ? getenv("TMPDIR") : "/tmp");

	toNativePath = function (p) { return p; };
	fromNativePath = function (p) { return p; };
	quotePath = function (p) { return "'" + p.replace(/'/g, "'\\''") + "'"; };
	quoteWildcardPath = function (p) { return p.replace(/[ ()<>'"&|$~!]/g, function (c) { return "\\" + c; }); };
	currentDir = function () { return appendDirSlash(pipe("pwd -L")); };

	renameFile = function (from, newName, throwOnError) {
		if (dirOfPath(newName) !== "") throw "Second argument to renameFile should not contain a directory";
		return shell("mv -i " + quotePath(from) + " " + quotePath(dirOfPath(from) + newName) + " </dev/null 1>/dev/null 2>&1"
				, throwOnError === undefined ? true : throwOnError);
	};

	pathExists = function (p) { return system("ls " + quoteWildcardPath(p) + " 1>/dev/null 2>&1") === 0; };

	isFileNewer = function (a, b) {
		var p0 = quotePath(a), p1 = quotePath(b);
		return system("test -e " + p0 + " -a ! -e " + p1 + " -o " + p0 + " -nt " + p1) === 0;
	};

	sleep = function (secs) { shell("sleep " + secs + " 1>/dev/null 2>&1"); };

	concatFiles = function () {
		var n = arguments.length, cmd = "cat", got = {};
		for (var i = 0; i < n - 1; ++i) { cmd += " " + quoteWildcardPath(arguments[i]); got["#" + arguments[i]] = true; }
		var d = arguments[n - 1];
		if (got.hasOwnProperty("#" + d)) throw "the destination file must not be one of the source files for concatFiles()";
		cmd += " 1>" + quotePath(d) + " 2>/dev/null";
		if (system(cmd) !== 0) throw "Error concatenating files with command: " + cmd;
	};

	// GNU coreutils (-c) vs BSD/macOS (-f) stat
	var statTimeOptions = "", statSizeOptions = "";
	discoverStatOptions = function () {
		if (statSizeOptions === "") {
			if (system("stat -c%y . 1>/dev/null 2>&1") === 0) {
				statTimeOptions = "-c%y";
				statSizeOptions = "-c%s";
			} else {
				statTimeOptions = '-f%Sm -t"%F %T"';
				statSizeOptions = "-f%z";
			}
		}
	};

	fileSize = function (p) {
		discoverStatOptions();
		var r = pipe("stat " + statSizeOptions + " " + quotePath(p));
		if (r === "") throw "Unable to obtain file size for " + p;
		return +r;
	};

	DIR_ORDER_OPTIONS = {
		"": { f: "", t: "" },
		"name": { f: "", t: "r" },
		"size": { f: "Sr", t: "S" },
		"time": { f: "tr", t: "t" }
	};

	dir = function (files, action, order, descending) {
		if (descending === undefined) descending = false;
		var options = DIR_ORDER_OPTIONS[order === undefined ? "" : order][descending ? "t" : "f"];
		if (files.charAt(files.length - 1) === "/") {
			// list the contents of a directory; names come back relative (with a trailing '/' for sub-dirs)
			tokenizeLines(pipe("ls -kp1" + options + " " + quoteWildcardPath(files), false), action);
		} else {
			// list each matching entry itself; strip the parent directory, keep any trailing '/'
			tokenizeLines(pipe("ls -kp1d" + options + " " + quoteWildcardPath(files), false), function (line) {
				var body = line.substring(0, line.length - 1);
				action(line.substring(rfindOfSet(body, "/") + 1));
			});
		}
	};

} else if (PLATFORM === "WINDOWS") {

	toNativePath = function (p) { return p.replace(/\//g, "\\"); };
	fromNativePath = function (p) { return p.replace(/\\/g, "/"); };
	quotePath = function (p) { return '"' + p.replace(/\//g, "\\") + '"'; };
	quoteWildcardPath = function (p) { return quotePath(p); };

	DIR_SLASH = "\\";
	DIR_SLASHES = "\\/:";
	DEL_COMMAND = "DEL /Q";
	MOVE_COMMAND = "MOVE";
	COPY_COMMAND = "COPY /Y";
	MKDIR_COMMAND = "MKDIR";
	RMDIR_COMMAND = "RMDIR /Q";
	WIPE_DIR_COMMAND = "RMDIR /S /Q";
	TEMP_DIR = appendDirSlash(fromNativePath(getenv("TEMP") !== undefined ? getenv("TEMP") : "\\temp"));
	DEV_NULL = "NUL";
	if (system("ECHO >NUL") !== 0) DEV_NULL = toNativePath(TEMP_DIR + "devnul"); // some stripped-down Windows lack NUL
	DIRECT_ALL_TO_NULL = "1>" + DEV_NULL + " 2>&1";

	currentDir = function () { return appendDirSlash(fromNativePath(pipe("cd"))); };

	renameFile = function (from, newName, throwOnError) {
		if (dirOfPath(newName) !== "") throw "Second argument to renameFile should not contain a directory";
		return shell("ren " + quotePath(from) + " " + quotePath(newName) + " " + DIRECT_ALL_TO_NULL
				, throwOnError === undefined ? true : throwOnError);
	};

	pathExists = function (p) { return system("IF NOT EXIST " + quoteWildcardPath(p) + " EXIT 1") === 0; };

	fileSize = function (p) {
		return +pipe("IF NOT EXIST " + quoteWildcardPath(p) + " (EXIT 1) ELSE (FOR %f IN (" + quotePath(p) + ") DO @ECHO %~zf)");
	};

	isFileNewer = function (a, b) {
		if (a === b) return false;
		if (dirOfPath(a) !== dirOfPath(b)) throw "Can only compare files in the same directory";
		var s = pipe("DIR /B /O-D " + quotePath(a) + " " + quotePath(b), false);
		var nl = s.indexOf("\n");
		return s.substring(0, nl < 0 ? s.length : nl) === filenameOfPath(a);
	};

	var sleepCommands = ["TIMEOUT /T {s}", "CHOICE /T {s} /D y"];
	var sleepCommandIndex = 0;
	sleep = function (secs) {
		var s = secs;
		while (true) {
			if (sleepCommandIndex < sleepCommands.length) {
				var c = sleepCommands[sleepCommandIndex].replace(/\{s\}/g, "" + Math.round(s));
				if (system(c + " " + DIRECT_ALL_TO_NULL) === 0) return;
				++sleepCommandIndex;
			} else {
				for (var et = time() + Math.round(s); time() < et;) {
					system("PING 123.45.67.89 -n 1 -w " + Math.round((et - time()) * 500) + " " + DIRECT_ALL_TO_NULL);
				}
				return;
			}
		}
	};

	concatFiles = function () {
		var n = arguments.length, cmd = "COPY /Y /B ", got = {};
		for (var i = 0; i < n - 1; ++i) {
			cmd += (i > 0 ? " + " : "") + quoteWildcardPath(arguments[i]);
			got["#" + arguments[i]] = true;
		}
		var d = arguments[n - 1];
		if (got.hasOwnProperty("#" + d)) throw "the destination file must not be one of the source files for concatFiles()";
		shell(cmd + " " + quotePath(d) + " " + DIRECT_ALL_TO_NULL);
	};

	DIR_ORDER_OPTIONS = {
		"": { f: "", t: "" },
		"name": { f: "/ON", t: "/O-N" },
		"size": { f: "/OS", t: "/O-S" },
		"time": { f: "/OD", t: "/O-D" }
	};

	dir = function (files, action, order, descending) {
		if (order === undefined) order = "";
		if (descending === undefined) descending = false;
		var singleFile;
		var dirs = {};
		var sawMarker = false;
		if (files.indexOf("*") < 0 && DIR_SLASHES.indexOf(files.charAt(files.length - 1)) < 0) {
			singleFile = filenameOfPath(files).toLowerCase();
			files += "*";
		}
		var options = DIR_ORDER_OPTIONS[order][descending ? "t" : "f"];
		var out = pipe("SET DIRCMD=&DIR /B /AD-H " + quoteWildcardPath(files) + "&ECHO \\&&DIR /B " + options + " "
				+ quoteWildcardPath(files), false);
		tokenizeLines(out, function (line) {
			if (line === "\\") sawMarker = true;
			else if (!sawMarker) dirs["#" + line] = true;
			else if (singleFile === undefined || line.toLowerCase() === singleFile) {
				action(line + (dirs.hasOwnProperty("#" + line) ? "/" : ""));
			}
		});
	};

} else {
	throw "Unsupported platform";
}
